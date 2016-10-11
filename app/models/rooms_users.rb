class RoomsUsers < ApplicationRecord
  enum status: {pending: 'pending', accepted: 'accepted', in_progress: 'in_progress', completed: 'completed'}
  
  belongs_to :room
  belongs_to :user

  validates_presence_of :room_id, :user_id

  after_create :send_asigned_room_email_to_user

  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }

  def send_asigned_room_email_to_user
    # UserNotifierMailer.delay(queue: :room).notify_asigned_room(self.room, self.user)
    UserNotifierMailer.notify_asigned_room(self.room, self.user).deliver_now
  end

  rails_admin do
    configure :user do
      associated_collection_cache_all false
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.freelancers.live
        }
      end
    end
  end

end
