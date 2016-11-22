class UnseenMessageAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :unseen_message_alert, backtrace: true

  # Alert user if there're new unseen messages
  def perform(room_id, user_id, user_type = :user)
    @room = Room.find(room_id)

    @recipient = if user_type == :user
      User.find(user_id)
    else
      Freelancer.find(user_id)
    end

    if @recipient.unseen_messages.where(room: @room).any?
      messages = @room.messages.includes(:user, :freelancer).order(:created_at).last(10)
      UserNotifierMailer.notify_unseen_messages(@room, @recipient, messages).deliver_now

      @recipient.unseen_messages.where(room: @room).destroy_all
    end
  end
end
