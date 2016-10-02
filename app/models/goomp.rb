# == Schema Information
#
# Table name: goomps
#
#  id                :integer          not null, primary key
#  name              :string
#  cover             :string
#  slug              :string
#  description       :string
#  memberships_count :integer          default(0)
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  logo              :string
#  price_cents       :integer
#  price_currency    :string           default("USD"), not null
#  rating            :float
#  reviews_count     :integer          default(0)
#  posts_count       :integer          default(0)
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
