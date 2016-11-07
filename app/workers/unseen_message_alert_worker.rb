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

    unseen_message_ids = @recipient.unseen_messages.where(room: @room).pluck(:message_id)
    return if unseen_message_ids.size.zero?

    messages = @room.messages.includes(:user, :freelancer).where(id: unseen_message_ids).order(created_at: :desc)

    users = messages.map(&:user).compact.uniq
    freelancers = messages.map(&:freelancer).compact.uniq

    users.each do |sender|
      msgs = messages.select{ |msg| msg.user == sender }
      UserNotifierMailer.notify_unseen_messages(@room, sender, @recipient, msgs).deliver_now
    end

    freelancers.each do |sender|
      msgs = messages.select{ |msg| msg.freelancer == sender }
      UserNotifierMailer.notify_unseen_messages(@room, sender, @recipient, msgs).deliver_now
    end

    @recipient.unseen_messages.where(room: @room).destroy_all
  end
end
