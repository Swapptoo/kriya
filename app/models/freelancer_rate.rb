class FreelancerRate < ApplicationRecord
  belongs_to :freelancer
  belongs_to :user
  belongs_to :room
  belongs_to :freelancers_room

  validates_presence_of :user_id, :freelancer_id, :room_id, :freelancers_room_id, :rate
end
