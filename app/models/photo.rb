# == Schema Information
#
# Table name: photos
#
#  id         :integer          not null, primary key
#  data       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Photo < ApplicationRecord
  mount_uploader :data, ImageUploader
end
