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
  has_many :slack_channels, dependent: :destroy
  belongs_to :user
  belongs_to :manager, class_name: "User"
  monetize :budget_cents

  has_many :freelancers_rooms, class_name: 'FreelancersRooms'
  has_and_belongs_to_many :asigned_freelancers, join_table: :freelancers_rooms, class_name: "Freelancer", after_add: :send_asigned_room_email_to_freelancer

  has_many :posts, :through => :messages

  has_many :freelancer_rates

  validates_presence_of :category_name

  before_create { self.category_name ||= "Design" }

  def accepted_freelancers
    self.asigned_freelancers.where("freelancers_rooms.status = 'accepted'")
  end

  def in_progress_freelancers
    self.asigned_freelancers.where("freelancers_rooms.status in (?)", ['accepted', 'not_finished', 'more_work'])
  end

  def pending_freelancers
    self.asigned_freelancers.where("freelancers_rooms.status = 'pending'")
  end

  def completed_freelancers
    self.asigned_freelancers.where("freelancers_rooms.status = 'completed'")
  end

  def create_unseen_messages(message, message_owner)
    users = []

    if user == message_owner
      users = accepted_freelancers.to_a
      users << manager
    elsif manager == message_owner
      users = accepted_freelancers.to_a
      users << user
    elsif accepted_freelancers.include?(message_owner)
      users << user
      users << manager
      users += accepted_freelancers.to_a
      users -= [message_owner]
    end

    users.each do |user|
      user.unseen_messages.create(message: message, room: message.room)
    end
  end

  def get_status(freelancer)
    freelancer_room = self.freelancers_rooms.where('freelancer_id = ?', freelancer.id)
    if freelancer_room.any?
      freelancer_room[0].status
    else
      ''
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

  def unfinish?
    messages.last.bot_description? || messages.last.slack_integration?
  end

  def finished?
    !unfinish?
  end

  def channel_name
    "kriya-#{title}"
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

  def get_room_name_for_freelancer(freelancer, index = nil)
    post = posts.first
    return '' if post.nil?
    post.title.parameterize
  end

  def get_index(user)
    user.joined_rooms.includes(:user).find_index(self)
  end

  def send_asigned_room_email_to_freelancer(record)
    UserNotifierMailer.delay(queue: :room).notify_asigned_room(self, record)
  end

  rails_admin do
    configure :asigned_freelancers do
      associated_collection_cache_all false
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.live
        }
      end
    end
  end
end
