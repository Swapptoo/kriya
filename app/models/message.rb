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
	 #  if (self.user.role != "freelancer") and (self.user.role != "manager") then
		# return
	 #  end

      if self.freelancer && self.freelancer.stripe_client_id.blank?
         self.update body: 'Freelancer didn\'t connect Stripe yet.'
      else

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
                    user_id: #{self.room.user.id},
                    freelancer_id: #{self.freelancer.nil? ? '' : self.freelancer.id}
                  }
                });
              e.preventDefault();
              location.reload();

            });
          </script>
          HTML
          title = "Change card"
          color = "white"
          update_customer = 1
        else
          if !self.user.nil?
            title = "Pay with card"
          elsif !self.freelancer.nil?
            title = "Yes, Pay with card"
          end 
          color = "green"
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
        if !self.user.nil?
          self.update body: "The charge for this task is $#{amount}, can you confirm so we can get it started?"
        elsif !self.freelancer.nil?
          freelancer_rooms = self.room.freelancers_rooms.where('status in (?)', ['accepted', 'more_work', 'not_finished']).where("freelancer_id = ?", self.freelancer.id)
          if freelancer_rooms.any?
            freelancer_room_id = freelancer_rooms[0].id
          else
            freelancer_room_id = ''
          end
          self.attachment.html += <<~HTML.squish
            <button id="customButton-#{self.id}-3" class="mini ui white button custom-padding">No</button>
            <script>
              document.getElementById("customButton-#{self.id}-3").addEventListener('click', function(e) {
                $.ajax({url: "/freelancers_rooms/#{freelancer_room_id}.json", type: "PUT", data: {
                    freelancers_room: {
                      status: 'not_finished'
                    }
                  }
                });
                e.preventDefault();
                location.reload();
              });
            </script>
          HTML
          self.update body: "The charge for this task is $#{amount}, did freelancer finish all the required things?"
        end
        self.attachment.save

        logger.debug self.inspect
        logger.debug self.attachment.html.inspect
        logger.debug self.errors.inspect
        logger.debug self.reload.inspect
      end
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
