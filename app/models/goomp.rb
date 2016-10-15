# == Schema Information
#
# Table name: goomps
#
#  cover             :string
#  created_at        :datetime         not null
#  description       :string
#  id                :integer          not null, primary key
#  logo              :string
#  memberships_count :integer          default(0)
#  name              :string
#  posts_count       :integer          default(0)
#  price_cents       :integer
#  price_currency    :string           default("USD"), not null
#  rating            :float
#  reviews_count     :integer          default(0)
#  slug              :string
#  updated_at        :datetime         not null
#  user_id           :integer
#
# Indexes
#
#  index_goomps_on_slug     (slug) UNIQUE
#  index_goomps_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_3bc0da7296  (user_id => users.id)
#

class Goomp < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  monetize :price_cents

  belongs_to :user, touch: true
  has_many :subtopics, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :reviews, dependent: :destroy

  validates :name, :logo, :description, :user, presence: true

  def has_member? user
    user && memberships.any? { |m| m.user_id == user.id }
  end

  def mini_cover
    filestack_id = self.cover.split('/').last
    "https://process.filestackapi.com/resize=width:290,height:130,fit:crop,align:center/#{filestack_id}"
  end
end
