# == Schema Information
#
# Table name: rooms
#
#  budget_cents    :integer          default(0), not null
#  budget_currency :string           default("USD"), not null
#  category_name   :string
#  created_at      :datetime         not null
#  description     :text
#  id              :integer          not null, primary key
#  manager_id      :integer
#  quality         :string
#  timeline        :string
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_rooms_on_manager_id  (manager_id)
#  index_rooms_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_676194d148  (manager_id => users.id)
#  fk_rails_a63cab0c67  (user_id => users.id)
#

class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :manager, class_name: "User"
  monetize :budget_cents

  has_many :rooms_users, class_name: 'RoomsUsers'
  has_and_belongs_to_many :asigned_users, join_table: :rooms_users, class_name: "User", after_add: :send_asigned_room_email_to_user

  has_many :posts, :through => :messages

  validates_presence_of :category_name

  before_create { self.category_name ||= "Design" }
  after_create :send_notification

  def get_status(user)
    if user.id == self.manager.id
      'manager'
    elsif user.id == self.user_id
      'owner'
    else
      room_user = self.rooms_users.where('user_id = ?', user.id)
      if room_user.any?
        room_user[0].status
      else
        ''
      end
    end
  end

  def room_name_for_manager(index)
    "#{self.user.slug}-#{self.category_name.downcase}-#{index+1}"
  end

  def room_name_for_client(index)
    "#{self.category_name&.downcase}-#{index+1}"
  end

  def title
    posts.first.try(:title)
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
    if user.freelancer?
      user.asigned_rooms.includes(:user).find_index(self)
    else
      user.joined_rooms.includes(:user).find_index(self)
    end
  end

  def send_asigned_room_email_to_user(record)
    UserNotifierMailer.notify_asigned_room(self, record).deliver_later(queue: :room)
  end

  rails_admin do
    configure :asigned_users do
      associated_collection_cache_all false
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.freelancers.live
        }
      end
    end
  end

  def notify_user?
    notify?(user)
  end

  def notify_manager?
    notify?(manager)
  end

  private

  def notify?(user)
    user.offline? && messages.not_by(user).un_seen.any?
  end

  def send_notification
    RoomWorker.perform_async(id)
  end
end
