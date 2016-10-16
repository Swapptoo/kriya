# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  body          :string
#  room_id       :integer
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  image         :string
#  post_id       :integer
#  seen          :boolean          default(FALSE)
#  freelancer_id :integer
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
  belongs_to :room
  belongs_to :user
  belongs_to :freelancer
  belongs_to :post
  has_one :attachment, dependent: :destroy


  # validate :body_or_image_present

  # after_create :process_command

  scope :un_seen, -> { where(seen: false) }
  scope :not_by, -> (user) { where.not(user: user) }

  def process_command
    if self.body =~ /\/charge \$?([\d\.]+)/
      amount = $1
      self.create_attachment html: "<br/>"
      if self.room.user.stripe_id != nil then
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
        title = "Change card"
        update_customer = 1
      else
        title = "Pay with card"
        update_customer = 0
      end
      self.attachment.html += <<~HTML.squish
      <script src="https://checkout.stripe.com/checkout.js"></script>
      <button id="customButton-#{self.id}-2" class="mini ui #{if not update_customer then "green" else "white" end} button custom-padding">#{title}</button>
        <script>
          var handler = StripeCheckout.configure({
            key: $("meta[name=stripePublishableKey]").attr("content"),
            image: 'https://www.filestackapi.com/api/file/6hx3CLg3SQGoARFjNBGq',
            locale: 'auto',
            amount: "#{(amount.to_f*100).to_i}",
            token: function(token) {
              return $.post("/payments.json", {
                token: token,
                amount: #{(amount.to_f*100).to_i},
                update_customer: #{update_customer},
                message_id: #{self.id},
                payment: {
                  user_id: #{self.room.user.id}
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
      self.attachment.save
      self.update body: "The charge for this task is $#{amount}, can you confirm so we can get it started?"
      logger.debug self.inspect
      logger.debug self.attachment.html.inspect
      logger.debug self.errors.inspect
      logger.debug self.reload.inspect
    end

    ActionCable.server.broadcast(
      "rooms:#{room.id}:messages",
      message: MessagesController.render(
        partial: 'messages/message',
        locals: {
          message: self, user: user
        }
      ),
      room_id: room.id,
    )
  end

  def body_or_image_present
    if self.body.blank? && self.image.blank? && self.attachment.blank?
      errors[:body] << ("Please write something")
    end
  end

  def within_60_secs_from_previous?
    message = previous_message
    !message.nil? && message.user == self.user && seconds_from_message(message) <= 60
  end

  def seconds_from_message(message = previous_message)
    (self.created_at.to_f - message.created_at.to_f)
  end

  def previous_message
    room.messages.where('id < ?', self.id).last
  end

  def next_message
    room.messages.where('id > ?', self.id).first
  end
end
