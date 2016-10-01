# == Schema Information
#
# Table name: rooms
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  manager_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_name   :string
#  budget_cents    :integer          default(0), not null
#  budget_currency :string           default("USD"), not null
#  timeline        :string
#  quality         :string
#  description     :text
#

class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :manager, class_name: "User"
  monetize :budget_cents

  has_many :posts, :through => :messages

  validates_presence_of :category_name
  before_create { self.category_name ||= "Design" }

  def room_name_for_manager(index)
    "#{self.user.slug}-#{self.category_name.downcase}-#{index+1}"
  end

  def room_name_for_client(index)
    "#{self.category_name&.downcase}-#{index+1}"
  end

  def get_room_name_for_user(user, index = nil)
    if user == self.user && !posts.first.nil?
      posts.first.title.parameterize
    elsif user == self.manager
      room_name_for_manager(index || self.get_index(user))
    else
      room_name_for_client(index || self.get_index(user))
    end
  end

  def get_index(user)
    user.joined_rooms.includes(:user).find_index(self)
  end
end
