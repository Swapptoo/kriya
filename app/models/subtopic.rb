# == Schema Information
#
# Table name: subtopics
#
#  created_at :datetime         not null
#  goomp_id   :integer
#  id         :integer          not null, primary key
#  name       :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subtopics_on_goomp_id  (goomp_id)
#
# Foreign Keys
#
#  fk_rails_893921a263  (goomp_id => goomps.id)
#

class Subtopic < ApplicationRecord
  belongs_to :goomp
end
