# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  body        :string
#  post_id     :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  likes_count :integer          default(0)
#

class Comment < ApplicationRecord
  include Likable
  belongs_to :post, touch: true
  belongs_to :user

  validates :body, presence: true
end
