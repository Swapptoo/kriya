# == Schema Information
#
# Table name: subtopics
#
#  id         :integer          not null, primary key
#  name       :string
#  goomp_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subtopic < ApplicationRecord
  belongs_to :goomp
end
