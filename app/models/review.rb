# == Schema Information
#
# Table name: reviews
#
#  body       :text
#  created_at :datetime         not null
#  goomp_id   :integer
#  id         :integer          not null, primary key
#  rating     :integer
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_reviews_on_goomp_id  (goomp_id)
#  index_reviews_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_74a66bd6c5  (user_id => users.id)
#  fk_rails_e6027eba90  (goomp_id => goomps.id)
#

class Review < ApplicationRecord
  belongs_to :goomp, counter_cache: true
  belongs_to :user

  after_create :update_goomp_rating

  def update_goomp_rating
    goomp.update rating: goomp.reviews.average(:rating)
  end
end
