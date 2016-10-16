# == Schema Information
#
# Table name: likes
#
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  likable_id   :integer
#  likable_type :string
#  updated_at   :datetime         not null
#  user_id      :integer
#
# Indexes
#
#  index_likes_on_likable_type_and_likable_id  (likable_type,likable_id)
#  index_likes_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_1e09b5dabf  (user_id => users.id)
#

class Like < ApplicationRecord
  belongs_to :likable, polymorphic: true, counter_cache: true
  belongs_to :user
end
