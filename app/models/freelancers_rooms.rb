class FreelancersRooms < ApplicationRecord
  enum status: {pending: 'pending', accepted: 'accepted', in_progress: 'in_progress', completed: 'completed'}
  
  belongs_to :room
  belongs_to :freelancer

  validates_presence_of :room_id, :freelancer_id

  after_create :send_asigned_room_email_to_freelancer

  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }

  def send_asigned_room_email_to_freelancer
    # UserNotifierMailer.delay(queue: :room).notify_asigned_room(self.room, self.user)
    UserNotifierMailer.notify_asigned_room(self.room, self.freelancer).deliver_now
  end

  rails_admin do
    configure :freelancer do
      associated_collection_cache_all false
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.live
        }
      end
    end
  end

end
