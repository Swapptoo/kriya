# == Schema Information
#
# Table name: messages
#
#  id                   :integer          not null, primary key
#  body                 :string
#  room_id              :integer
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  image                :string
#  post_id              :integer
#  seen                 :boolean          default(FALSE)
#  freelancer_id        :integer
#  msg_type             :string
#  slack_ts             :string
#  slack_channel        :string
#  source               :integer          default("kriya")
#  one_mn_from_previous :boolean          default(FALSE)
#  deleted_at           :datetime
#
# Indexes
#
#  index_messages_on_freelancer_id  (freelancer_id)
#  index_messages_on_post_id        (post_id)
#  index_messages_on_room_id        (room_id)
#  index_messages_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_273a25a7a6  (user_id => users.id)
#  fk_rails_a8db0fb63a  (room_id => rooms.id)
#  fk_rails_f36d097b9e  (post_id => posts.id)
#  fk_rails_f9bcdb85dc  (freelancer_id => freelancers.id)
#

class Message < ApplicationRecord
  mount_uploader :image, ImageUploader
  acts_as_paranoid

  enum source: { kriya: 0, email: 1, slack: 2 }

  belongs_to :room
  belongs_to :user
  belongs_to :freelancer
  belongs_to :post
  has_one :attachment, dependent: :destroy

  scope :un_seen, -> { where(seen: false) }
  scope :not_by,  -> (user) { where.not(user: user) }
  scope :by,      -> (user) { where(user: user) }

  scope :not_by_freelancer, -> (freelancer) { where.not(freelancer: freelancer) }
  scope :by_freelancer,     -> (freelancer) { where(freelancer: freelancer) }

  before_create :ensure_one_mn_from_previous
  after_commit :set_room_last_message_created_at, :notify_slack, on: :create

  def self.for_freelancer
    exclude_typs = [
      'bot-reject-slack',
      'bot-thanks-client',
      'bot-remark-time-diff',
      'ask-more',
      'add-website',
      'bot-charge-success',
      'bot-charge-task',
      'slack-client',
      'bot-failed-payment',
      'slack-manager',
      'add-total-employee'
    ]

    self.where('msg_type NOT IN (?) OR msg_type IS NULL', exclude_typs)
  end

  def process_command
    if self.body =~ /\/charge \$?([\d\.]+)/
      amount = $1

      self.create_attachment html: "<br/>"

      if self.room.user.stripe_id.present?
        self.attachment.html += <<~HTML.squish
          <button id="customButton-#{self.id}" class="mini ui green button custom-padding">Pay</button>
          <script>
            document.getElementById("customButton-#{self.id}").addEventListener('click', function(e) {
              $.post("/payments.json", {
                  amount: #{(amount.to_f*100).to_i},
                  message_id: #{self.id},
                  payment: {
                    user_id: #{self.room.user.id}
                  }
                });
              e.preventDefault();
            });
          </script>
        HTML

        title = 'Change card'
        color = 'white'
        update_customer = 1
      else
        title = 'Pay with card' if self.user.present?
        color = 'green'
        update_customer = 0
      end

      self.attachment.html += <<~HTML.squish
        <script src="https://checkout.stripe.com/checkout.js"></script>
        <button id="customButton-#{self.id}-2" class="mini ui #{color} button custom-padding">#{title}</button>
        <script>
          var handler = StripeCheckout.configure({
            key: $("meta[name=stripePublishableKey]").attr("content"),
            image: 'https://www.filestackapi.com/api/file/6hx3CLg3SQGoARFjNBGq',
            locale: 'auto',
            amount: "#{(amount.to_f*100).to_i}",
            closed: function() { location.reload(); },
            token: function(token) {
              return $.post("/payments.json", {
                token: token,
                amount: "#{(amount.to_f*100).to_i}",
                update_customer: "#{update_customer}",
                message_id: "#{self.id}",
                payment: {
                  user_id: "#{self.room.user.id}"
                }
              });
            }
          });

          document.getElementById("customButton-#{self.id}-2").addEventListener('click', function(e) {
            handler.open({
              name: 'Kriya',
              zipCode: true,
              amount: "#{(amount.to_f*100).to_i}"
            });
            e.preventDefault();
          });

          window.addEventListener('popstate', function() {
            handler.close();
          });
        </script>
      HTML

      if self.msg_type == 'bot-half-charge-task'
        self.update(body: "And please pay <strong>$#{amount}</strong> of the budget that goes into Kriya's Escrow. It'll be paid to the workforce ONLY after the successful completion of the work, otherwise we revert it.")
      else
        self.update(body: "Please pay the charge <strong>$#{amount}</strong>, so we pay the workforce?", msg_type: 'bot-charge-task')
      end

      self.attachment.save
    end

    ActionCable.server.broadcast(
      "rooms:#{room.id}:messages",
      message: MessagesController.render(
        partial: 'messages/message',
        locals: {
          message: self, user: (user.presence || freelancer)
        }
      ),
      room_id: room.id,
      is_user: 'user'
    )

    self.room.in_progress_freelancers.each do |freelancer|
      ActionCable.server.broadcast(
        "rooms:#{room.id}:messages",
        message: MessagesController.render(
          partial: 'messages/message',
          locals: {
            message: self, user: freelancer
          }
        ),
        room_id: room.id,
        is_user: 'freelancer'
      )
    end

    self.room.completed_freelancers.each do |freelancer|
      ActionCable.server.broadcast(
        "rooms:#{room.id}:messages",
        message: MessagesController.render(
          partial: 'messages/message',
          locals: {
            message: self, user: freelancer
          }
        ),
        room_id: room.id,
        is_user: 'freelancer'
      )
    end
  end

  def body_or_image_present
    if self.body.blank? && self.image.blank? && self.attachment.blank?
      errors[:body] << ("Please write something")
    end
  end

  def ensure_one_mn_from_previous
    puts "run callback"
    last_msg = room.messages.last
    self.one_mn_from_previous = true if last_msg.present? && last_msg.user == self.user && (Time.current.to_f - last_msg.created_at.to_f) <= 60
  end

  def within_60_secs_from_previous?
    try :one_mn_from_previous?
  end

  def seconds_from_message(message = previous_message)
    (self.created_at.to_f - message.created_at.to_f)
  end

  def previous_message
    @previous_message ||= room.messages.where('id < ?', self.id).last
  end

  def next_message
    room.messages.where('id > ?', self.id).first
  end

  def bot_description?
    msg_type == 'bot-description'
  end

  def slack_integration?
    msg_type == 'slack-integration'
  end

  def owner
    self.user.presence || self.freelancer
  end

  def slack?
    msg_type.present? && msg_type.include?('slack')
  end

  def attachment_right?
    slack? ||
    msg_type == 'add-website' ||
    msg_type == 'add-total-employee'
  end

  def bot_to_freelancer?
    ['slack-freelancer'].include?(msg_type)
  end

  def bot_to_client?
    ['slack-client'].include?(msg_type)
  end

  def bot_task_accepted?
    msg_type == 'bot-task-accepted'
  end

  def to_slack(slack_channel, as_user = false)
    if image?
      text = (as_user || user.try(:manager?)) ? '' : "*#{owner.first_name}*"

      {
        attachments: [
          {
            image_url: image.url,
            text: image.file.filename
          }
        ],
        text: text,
        channel: slack_channel,
        as_user: as_user
      }

    elsif file?
      {
        content: IO.copy_stream(open(image.url), image.file.filename),
        filename: image.file.filename,
        channel: slack_channel
      }
    elsif post.present?
      text = "I've just created a task at #{post.public_url}"
      text = "*#{owner.first_name}*: #{text}" unless as_user || user.try(:manager?)

      {
        text: text,
        as_user: as_user,
        channel: slack_channel
      }
    else
      text = self.body
      text = "*#{owner.first_name}*: #{text}" unless as_user || user.try(:manager?)

      {
        text: text,
        as_user: as_user,
        channel: slack_channel
      }
    end
  end

  def file?
    image.file.present? && image.not_image?
  end

  def image?
    image.file.present? && image.image?
  end

  private

  def owner_full_name
    owner.full_name
  end

  def notify_slack
    SlackWorker.perform_async(id) if msg_type.nil?
  end

  def set_room_last_message_created_at
    room.update_column(:last_message_created_at, self.created_at)
  end
end
