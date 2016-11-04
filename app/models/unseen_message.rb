# == Schema Information
#
# Table name: unseen_messages
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  freelancer_id :integer
#  message_id    :integer
#  room_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_unseen_messages_on_freelancer_id  (freelancer_id)
#  index_unseen_messages_on_message_id     (message_id)
#  index_unseen_messages_on_room_id        (room_id)
#  index_unseen_messages_on_user_id        (user_id)
#

class UnseenMessage < ApplicationRecord
  belongs_to :room
  belongs_to :user
  belongs_to :message
  belongs_to :freelancer

  scope :by_user,         -> (user) { where(user: user) }
  scope :by_freelancer,   -> (freelancer) { where(freelancer: freelancer) }
end
