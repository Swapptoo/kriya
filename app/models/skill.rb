# == Schema Information
#
# Table name: skills
#
#  id       :integer          not null, primary key
#  skill    :string
#  category :string
#

class Skill < ApplicationRecord

  def to_select2
    {
      id: id,
      text: skill
    }
  end
end
