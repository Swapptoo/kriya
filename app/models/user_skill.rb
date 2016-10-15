# == Schema Information
#
# Table name: user_skills
#
#  id       :integer          not null, primary key
#  skill_id :integer
#  user_id  :integer
#
# Indexes
#
#  index_user_skills_on_user_id_and_skill_id  (user_id,skill_id) UNIQUE
#

class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill

  validates_presence_of :skill_id, :user_id
end
