if Rails.env.production?
  SlackChannel.update_all(sync: false)
  SlackChannel.where(sync: false, status: 1).find_each do |slack_channel|
    slack_channel.sync!
  end
end
