class SlackWorker
  include Sidekiq::Worker
  sidekiq_options queue: :slack, backtrace: true

  def perform(message_id)
    message = Message.find_by(id: message_id)

    return if message.nil?
    return if message.msg_type.present?

    owner = message.owner
    room  = message.room

    recipients = []

    if room.user == owner
      recipients = room.in_progress_freelancers.to_a
      recipients << room.manager
    elsif room.manager == owner
      recipients = room.in_progress_freelancers.to_a
      recipients << room.user
    elsif room.in_progress_freelancers.include?(owner)
      recipients << room.user
      recipients << room.manager
      recipients += room.in_progress_freelancers.to_a
      recipients -= [owner]
    end

    recipients.each do |recipient|
      slack_channel = recipient.slack_channels.find_by(room: room)
      next if slack_channel.nil? || slack_channel.inactive?

      client = Slack::Web::Client.new token: slack_channel.token
      slack_message = client.chat_postMessage(message.to_slack(slack_channel.channel_id))

      room.message_slack_histories.create(ts: slack_message.ts)
    end

    # Record owner message
    return if message.slack_ts.present?
    slack_channel = owner.slack_channels.find_by(room: room)

    return if slack_channel.nil? || slack_channel.inactive?

    client = Slack::Web::Client.new token: slack_channel.token
    slack_message = client.chat_postMessage(message.to_slack(slack_channel.channel_id, true))

    room.message_slack_histories.create(ts: slack_message.ts)
  end
end
