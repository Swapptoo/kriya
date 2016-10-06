# == Schema Information
#
# Table name: freelancer_profiles
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  category                   :string
#  availability               :datetime
#  primary_skill              :integer
#  years_of_experiences       :string
#  project_description        :string
#  project_url                :string
#  professional_profile_link1 :string
#  professional_profile_link2 :string
#  status                     :string           default("pause")
#

class FreelancerProfile < ActiveRecord::Base
  belongs_to :user

  enum status: {pause: 'pause', live: 'live'}
  
  validates :category, :availability, :primary_skill, :years_of_experiences, :project_description, :project_url, :professional_profile_link1, presence: true

end
