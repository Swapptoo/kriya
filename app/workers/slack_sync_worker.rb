class SlackSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :slack_sync, backtrace: true

  def perform(slack_channel_id)
    slack_channel = SlackChannel.find_by(id: slack_channel_id)

    return if slack_channel.nil?

    slack_channel.sync? || slack_channel.sync!
  end
end
