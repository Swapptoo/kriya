# == Schema Information
#
# Table name: slack_channels
#
#  id            :integer          not null, primary key
#  channel_id    :string
#  uid           :string
#  token         :string
#  web_hook_url  :string
#  scope         :string
#  team_name     :string
#  team_id       :string
#  room_id       :integer
#  user_id       :integer
#  freelancer_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status        :integer          default("inactive")
#  sync          :boolean          default(FALSE)
#
# Indexes
#
#  index_slack_channels_on_freelancer_id  (freelancer_id)
#  index_slack_channels_on_room_id        (room_id)
#  index_slack_channels_on_user_id        (user_id)
#

class SlackChannel < ApplicationRecord
  enum status: { active: 1, inactive: 0 }

  belongs_to :room
  belongs_to :user
  belongs_to :freelancer

  validates :uid,
            :token,
            :team_name,
            :team_id, presence: true, if: :active?

  def sync!
    client = Slack::RealTime::Client.new(token: self.token, websocket_ping: 50)

    client.on :hello do
      update!(sync: true)
      puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
    end

    client.on :message do |data|
      if data.user == self.uid && data.channel == self.channel_id
        puts data
        message_owner = user.presence || freelancer
        body = Slack::Messages::Formatting.unescape(data.text)

        if room.messages.where(body: body, user: user, freelancer: freelancer, slack_channel: data.channel).any?
          message = room.messages.create(body: body, user: user, freelancer: freelancer, slack_ts: data.ts, slack_channel: data.channel)
          message.process_command
          room.create_unseen_messages(message, message_owner)
        end
      end
    end

    client.on :close do |_data|
      puts 'Client is about to disconnect'
    end

    client.on :closed do |_data|
      puts 'Client has disconnected successfully!'

      update(sync: false)
    end

    client.start_async
  end
end
