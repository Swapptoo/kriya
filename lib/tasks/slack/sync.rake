namespace :slack do
  desc 'Init slack rtm'
  task sync: :environment do
    SlackChannel.where(sync: false, status: 1).ids.each do |slack_channel_id|
      SlackSyncWorker.perform_async(slack_channel_id)
    end
  end
end
