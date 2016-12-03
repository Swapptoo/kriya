namespace :slack do
  desc 'Init slack rtm'
  task sync: :environment do
    SlackChannel.where(sync: false, status: 'active').each do |slack_channel|
      slack_channel.sync! unless slack_channel.sync?
    end
  end
end
