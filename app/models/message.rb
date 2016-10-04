class Message < ApplicationRecord
  mount_uploader :image, ImageUploader
  belongs_to :room
  belongs_to :user
  belongs_to :post
  has_one :attachment, dependent: :destroy

  validates_presence_of :room, :user

  # validate :body_or_image_present

  # after_create :process_command

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
                update_customer: false,
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
        update_customer = false
      else
        title = "Pay with card"
        update_customer = true
      end
      self.attachment.html += <<~HTML.squish
      <script src="https://checkout.stripe.com/checkout.js"></script>
      <button id="customButton-#{self.id}-2" class="mini ui #{if update_customer then "green" else "white" end} button custom-padding">#{title}</button>
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
