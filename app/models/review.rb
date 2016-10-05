# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  goomp_id   :integer
#  user_id    :integer
#  rating     :integer
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Review < ApplicationRecord
  belongs_to :goomp, counter_cache: true
  belongs_to :user

  after_create :update_goomp_rating

  def update_goomp_rating
    goomp.update rating: goomp.reviews.average(:rating)
  end
end
