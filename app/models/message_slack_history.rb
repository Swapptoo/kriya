# == Schema Information
#
# Table name: message_slack_histories
#
#  id         :integer          not null, primary key
#  ts         :string
#  room_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MessageSlackHistory < ApplicationRecord
end
