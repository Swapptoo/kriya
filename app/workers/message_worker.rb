class MessageWorker
  include Sidekiq::Worker
  sidekiq_options queue: :message, backtrace: true

  def perform(id)
    @message = Message.find(id)
    notify_user unless @message.seen?
  end

  private

  def notify_user
    room = @message.room
    user = room.manager
    user = room.user if room.manager == @message.user
    UserNotifierMailer.notify_unseen_message(@message, user).deliver_now unless user.online?
  end
end
