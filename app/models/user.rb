# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  bio                    :string
#  first_name             :string
#  last_name              :string
#  picture                :string
#  headline               :string
#  work_experience        :string
#  gender                 :string           default("male")
#  avatar                 :string
#  slug                   :string
#  stipe_customer_id      :string
#  follows_count          :integer          default(0)
#  role                   :string
#  last_seen_at           :datetime
#  stripe_id              :string
#

class User < ApplicationRecord
  include Followable
  enum role: {client: 'client', freelancer: 'freelancer', manager: 'manager'}
  
  devise :database_authenticatable, :registerable, :omniauthable, :recoverable, :rememberable, :trackable, :validatable

  has_many :goomps, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :joined_goomps, through: :memberships, class_name: "Goomp", source: :goomp
  has_many :posts_from_joined_goomps, through: :joined_goomps, source: :posts
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :rooms, dependent: :destroy
  has_many :managed_rooms, dependent: :destroy, class_name: "Room", foreign_key: :manager_id
  has_many :messages, dependent: :destroy

  has_and_belongs_to_many :rooms_users, class_name: 'RoomsUsers'
  has_and_belongs_to_many :asigned_rooms, join_table: :rooms_users, class_name: "Room", after_add: :send_asigned_room_email_to_user

  has_many :user_skills
  has_many :skills, through: :user_skills, dependent: :destroy
  has_one :profile, class_name: 'FreelancerProfile'

  accepts_nested_attributes_for :profile, allow_destroy: true

  scope :freelancers, -> { where(role: 'freelancer') }

  scope :live, lambda {
    joins(:profile).where('freelancer_profiles.status = ?', 'live')
  }

  def live?
    if self.profile
      self.profile.status == 'live'
    else
      true
    end
  end

  def pending_rooms
    self.asigned_rooms.where(rooms_users: { status: 'pending' })
  end

  def accepted_rooms
    self.asigned_rooms.where(rooms_users: { status: 'accepted' })
  end

  def joined_rooms
    if self.freelancer?
      accepted_rooms
    else
      Room.where("user_id = ? OR manager_id = ?", self.id, self.id).order("created_at desc")
    end
  end

  validates :first_name, :last_name, :picture, :headline, presence: true

  extend FriendlyId
  friendly_id :full_name, use: :slugged


  def is_manager_of? goomp
    goomp.user == self
  end

  def manager?
    self.role == 'manager'
  end

  def freelancer?
    self.role == 'freelancer'
  end
  
  def client?
    self.role == 'client' || self.role.blank? 
  end

  def online?
    last_seen_at > 15.minutes.ago
  end
  
  def full_name
    [first_name, last_name].join(' ')
  end

  def name
    [first_name, last_name].join(' ')
  end

  def join goomp, token = nil
    membership = Membership.where(user: self, goomp: goomp).first_or_initialize

    if membership.persisted?
      if goomp.user_id == self.id
        # Founder can't unjoin his own group
        return false
      else
        membership.destroy
      end
    else
      if goomp.price > 0
        StripeService.subscribe self, goomp, token
      end

      membership.save
    end
  end

  def send_asigned_room_email_to_user(record)
    UserNotifierMailer.delay(queue: :room).notify_asigned_room(record, self)
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

  rails_admin do
    list do
      field :email
      field :first_name
      field :last_name
      field :professional_profile_link do
        formatted_value{ bindings[:object].profile ? bindings[:object].profile.professional_profile_link1 : "" }
      end
      field :status do
        formatted_value{ bindings[:object].profile ? bindings[:object].profile.status : "" }
      end
      field :role
      field :headline
      field :gender
    end

    update do
      field :email
      field :first_name
      field :last_name
      field :headline
      field :gender
      field :role
      field :profile
      field :password
      field :asigned_rooms
    end

  end

  private
  def update_status
    if self.profile
      new_status = self.profile.status == 'pause' ? 'live' : 'pause'
      self.profile.update_attribute(:status, new_status)
    end
  end
end
