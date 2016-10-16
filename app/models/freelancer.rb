class Freelancer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  enum status: {pause: 'pause', live: 'live'}
  
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable 

  validates :first_name, :last_name, :picture, :headline, :category, :availability, :primary_skill, :years_of_experiences, :project_description, :project_url, :professional_profile_link1, presence: true
  
  before_save :ensure_authentication_token


  has_many :freelancer_skills
  has_many :skills, through: :freelancer_skills, dependent: :destroy

  has_many :freelancers_rooms, class_name: 'FreelancersRooms'
  has_and_belongs_to_many :asigned_rooms, join_table: :freelancers_rooms, class_name: "Room", after_add: :send_asigned_room_email_to_freelancer
  has_many :messages, dependent: :destroy
  
  scope :live, -> { where(status: 'live') }

  def full_name
    [first_name, last_name].join(' ')
  end

  def pending_rooms
    self.asigned_rooms.where(freelancers_rooms: { status: 'pending' })
  end

  def accepted_rooms
    self.asigned_rooms.where(freelancers_rooms: { status: 'accepted' })
  end

  def send_asigned_room_email_to_freelancer(record)
    # UserNotifierMailer.delay(queue: :room).notify_asigned_room(record, self)
    UserNotifierMailer.notify_asigned_room(record, self).deliver_now
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = loop do
        token = Devise.friendly_token
        break token unless Freelancer.where(authentication_token: token).first
      end
    end
  end

  def self.from_omniauth auth
    authdata = case auth.provider
    when "twitter"
      {
        email: auth.info.email,
        first_name: auth.info.name.split(" ").first,
        picture: auth.info.image.gsub("_normal", ""),
        last_name: auth.info.name.split(" ").last,
        uid: auth.uid,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        username: auth.info.nickname,
        provider: "twitter"
      }
    when "linkedin"
      {
        email: auth.info.email,
        first_name: auth.info.first_name,
        picture: auth.extra.raw_info.pictureUrls.values.last.last,
        last_name: auth.info.last_name,
        uid: auth.uid,
        headline: auth.info.description,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        provider: "linkedin"
      }
    when "facebook"
      {
        email: auth.info.email,
        first_name: auth.info.first_name,
        picture: auth.info.image.gsub("square", "large"),
        last_name: auth.info.last_name,
        uid: auth.uid,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        provider: "facebook"
      }
    end

    auth = Authorization.find_by uid: authdata[:uid], provider: authdata[:provider]

    return auth&.user || authdata
  end


  def update_status
    if self.profile
      new_status = self.profile.status == 'pause' ? 'live' : 'pause'
      self.profile.update_attribute(:status, new_status)
    end
  end
end
