
class FreelancerAuthorization < ApplicationRecord
  belongs_to :freelancer
  validates :uid, :provider, presence: true
end
