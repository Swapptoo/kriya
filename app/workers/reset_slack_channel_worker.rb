class ResetSlackChannelWorker
  include Sidekiq::Worker
  sidekiq_options queue: :slack, backtrace: true

  def perform(freelancer_id, room_id)
    freelancer = Freelancer.find_by(id: freelancer_id)
    room = Room.find_by(id: room_id)
    slack_channel = freelancer.slack_channel.find_by(room: room)

    return if [freelancer, room, slack_channel].any?(:nil?)

    messages = room.messages.where(msg_type: nil, slack_channel: room.channel_name).where.not(slack_ts: nil)
    client = Slack::Web::Client.new token: slack_channel.token

    messages.each do |msg|
      client.chat_delete(ts: msg.slack_ts, channel: room.channel_name)
    end
  end
end
