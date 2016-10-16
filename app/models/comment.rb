# == Schema Information
#
# Table name: comments
#
#  body        :string
#  created_at  :datetime         not null
#  id          :integer          not null, primary key
#  likes_count :integer          default(0)
#  post_id     :integer
#  updated_at  :datetime         not null
#  user_id     :integer
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_03de2dc08c  (user_id => users.id)
#  fk_rails_2fd19c0db7  (post_id => posts.id)
#

class Comment < ApplicationRecord
  include Likable
  belongs_to :post, touch: true
  belongs_to :user

  validates :body, presence: true
end
