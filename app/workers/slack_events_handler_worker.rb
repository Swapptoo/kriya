class SlackEventsHandlerWorkerSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :slack_events_handler, backtrace: true

  def perform(slack_params)
    slack = slack_params.to_ostruct
    authed_users = slack.authed_users
    slack_event = slack.event

    slack_channel = SlackChannel.find_by(uid: authed_users, channel_id: slack_event.channel)

    return if slack_channel.nil? || slack_event.hidden == true || (slack_event.subtype.present? && slack_event.file.blank?)

    message_owner = slack_channel.user.presence || slack_channel.freelancer
    body = Slack::Messages::Formatting.unescape(slack_event.text)
    room = slack_channel.room

    if room.message_slack_histories.find_by(ts: slack_event.ts).blank? && room.messages.find_by(body: body, user: slack_channel.user, freelancer: slack_channel.freelancer, created_at: 20.seconds.ago..0.second.ago).blank?
      message = room.messages.create(source: 'slack', body: body, user: slack_channel.user, freelancer: slack_channel.freelancer, slack_ts: slack_event.ts, slack_channel: slack_event.channel)

      if slack_event.file.present?
        if slack_event.file.external_type == 'gdrive'
          message.body += "</br>#{slack_event.file.url_private}"
          message.save
        else
          web_client = Slack::Web::Client.new(token: slack_channel.token)
          file = web_client.files_sharedPublicURL(file: slack_event.file.id)

          if file.ok?
            message.remote_image_url = "#{file.file.url_private}?pub_secret=#{file.file.permalink_public.split('-').last}"
            message.save
          end

          web_client.files_revokePublicURL(file: slack_event.file.id)
        end
      end

      message.process_command

      room.message_slack_histories.create(ts: slack_event.ts)

      message_owner.unseen_messages.where(room: room).destroy_all
      room.create_unseen_messages(message, message_owner)
    end
  end
end
