# == Schema Information
#
# Table name: freelancer_profiles
#
#  availability               :datetime
#  category                   :string
#  hourly_rate                :integer          default(0), not null
#  id                         :integer          not null, primary key
#  primary_skill_id           :integer
#  professional_profile_link1 :string
#  professional_profile_link2 :string
#  project_description        :string
#  project_url                :string
#  status                     :string           default("pause")
#  user_id                    :integer
#  years_of_experiences       :string
#
# Indexes
#
#  index_freelancer_profiles_on_user_id  (user_id)
#

class FreelancerProfile < ActiveRecord::Base
  attr_accessor :hourly_rate_in_dollar

  belongs_to :user
  belongs_to :primary_skill, class_name: 'Skill'

  enum status: {pause: 'pause', live: 'live'}

  validates :category, :hourly_rate, :availability, :primary_skill, :years_of_experiences, :project_description, :project_url, :professional_profile_link1, presence: true
  validates :hourly_rate_in_dollar, numericality: { greater_than: 0 }

  before_save :convert_hourly_rate_to_cent

  private

  def convert_hourly_rate_to_cent
    self.hourly_rate = (hourly_rate_in_dollar.to_f * 100).to_i if hourly_rate_in_dollar
  end
end
