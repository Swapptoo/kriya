# == Schema Information
#
# Table name: skills
#
#  category :string
#  id       :integer          not null, primary key
#  skill    :string
#

class Skill < ApplicationRecord
  def title
    self.skill
  end
end
