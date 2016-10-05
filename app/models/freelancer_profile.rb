class FreelancerProfile < ActiveRecord::Base
  belongs_to :user

  enum status: {pause: 'pause', live: 'live'}
  
  validates :category, :availability, :primary_skill, :years_of_experiences, :project_description, :project_url, :professional_profile_link1, presence: true

end