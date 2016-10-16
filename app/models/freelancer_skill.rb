# == Schema Information
#
# Table name: freelancer_skills
#
#  id            :integer          not null, primary key
#  freelancer_id :integer
#  skill_id      :integer
#
# Indexes
#
#  index_freelancer_skills_on_freelancer_id_and_skill_id  (freelancer_id,skill_id) UNIQUE
#

class FreelancerSkill < ApplicationRecord
  belongs_to :freelancer
  belongs_to :skill

  validates_presence_of :skill_id, :freelancer_id
end
