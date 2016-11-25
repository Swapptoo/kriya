class SlackWorker
  include Sidekiq::Worker
  sidekiq_options queue: :slack, backtrace: true

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return if message.nil? || message.msg_type.present?

    owner = message.owner
    room  = message.room

    recipients = []
    recipients += room.accepted_freelancers if room.accepted_freelancers.exclude?(owner)
    recipients << room.user if room.user != owner
    recipients << room.manager if room.manager != owner

    recipients.each do |recipient|
      slack_channel = recipient.slack_channels.find_by(room: room)
      next if slack_channel.nil?

      client = Slack::Web::Client.new token: slack_channel.token
      client.chat_postMessage(message.to_slack)
    end

    # Record owner message
    slack_channel = owner.slack_channels.find_by(room: room)

    return if slack_channel.nil?

    client = Slack::Web::Client.new token: slack_channel.token
    client.chat_postMessage(message.to_slack(true))
  end
end
