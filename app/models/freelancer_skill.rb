# == Schema Information
#
# Table name: user_skills
#
#  id       :integer          not null, primary key
#  user_id  :integer
#  skill_id :integer
#

class FreelancerSkill < ApplicationRecord
  belongs_to :freelancer
  belongs_to :skill

  validates_presence_of :skill_id, :freelancer_id
end
