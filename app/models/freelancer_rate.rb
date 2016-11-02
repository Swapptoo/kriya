# == Schema Information
#
# Table name: freelancer_rates
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rate                :integer
#  freelancer_id       :integer
#  user_id             :integer
#  room_id             :integer
#  freelancers_room_id :integer
#
# Indexes
#
#  index_freelancer_rates_on_freelancer_id        (freelancer_id)
#  index_freelancer_rates_on_freelancers_room_id  (freelancers_room_id)
#  index_freelancer_rates_on_room_id              (room_id)
#  index_freelancer_rates_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_0cc87bd5ae  (freelancers_room_id => freelancers_rooms.id)
#  fk_rails_16bf63615b  (freelancer_id => freelancers.id)
#  fk_rails_55b4ecc013  (room_id => rooms.id)
#  fk_rails_c261c0febb  (user_id => users.id)
#

class FreelancerRate < ApplicationRecord
  belongs_to :freelancer
  belongs_to :user
  belongs_to :room
  belongs_to :freelancers_room

  validates_presence_of :user_id, :freelancer_id, :room_id, :freelancers_room_id, :rate
end
