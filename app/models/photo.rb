# == Schema Information
#
# Table name: photos
#
#  created_at :datetime         not null
#  data       :text
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#

class Photo < ApplicationRecord
  mount_uploader :data, ImageUploader
end
