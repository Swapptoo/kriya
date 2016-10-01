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

    # Message created by manager, notify client
    if room.manager == @message.user
      puts "notify client"
      UserNotifierMailer.notify_unseen_message(@message, @message.user).deliver_now
    else
      puts "notify manager"
      UserNotifierMailer.notify_unseen_message(@message, @message.manager).deliver_now
    end
  end
end
