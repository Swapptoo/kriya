# == Schema Information
#
# Table name: slack_channels
#
#  id            :integer          not null, primary key
#  name          :string
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

  validates :name,
            :uid,
            :token,
            :web_hook_url,
            :team_name,
            :team_id, presence: true, if: :active?
end
