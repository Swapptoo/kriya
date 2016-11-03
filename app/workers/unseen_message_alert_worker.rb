class UnseenMessageAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :unseen_message_alert, backtrace: true

  # Alert user if there're new unseen messages
  def perform(room_id, user_id)
    room = Room.find(room_id)
    user = User.find(user_id)
    another_user = room.manager
    another_user = room.user if room.manager == user
    messages = room.messages.not_by(user).un_seen.order(:created_at)

    return if messages.size.zero?
    
    UserNotifierMailer.notify_unseen_messages(room, user, another_user, messages).deliver_now
  end
end
