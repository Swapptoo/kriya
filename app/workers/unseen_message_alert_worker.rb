class UnseenMessageAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :unseen_message_alert, backtrace: true

  # Alert user if there're new unseen messages
  def perform(room_id, user_id, user_type = :user)
    @room = Room.find(room_id)
    messages = []

    if user_type == :user
      @sender = User.find(user_id)
      messages = @room.messages.by(@sender).un_seen.order(:created_at)
    else
      @sender = Freelancer.find(user_id)
      messages = @room.messages.by_freelancer(@sender).un_seen.order(:created_at)
    end

    return if messages.size.zero?

    recipients.each do |recipient|
      UserNotifierMailer.notify_unseen_messages(@room, @sender, recipient, messages).deliver_now
    end

    messages.update_all(seen: true)
  end

  private

  def recipients
    users = []

    if @room.user == @sender
      users = @room.accepted_freelancers.to_a
      users << @room.manager
    elsif @room.manager == @sender
      users = @room.accepted_freelancers.to_a
      users << @room.user
    elsif @room.accepted_freelancers.include?(@sender)
      users = @room.accepted_freelancers.to_a
      users -= [@sender]
      users << @room.user
      users << @room.manager
    end

    users.select(&:offline?)
  end
end
