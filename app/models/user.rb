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
#  last_seen_at           :datetime
#  role                   :string           default(NULL)
#  stripe_id              :string
#  authentication_token   :string(30)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  include Followable
  acts_as_token_authenticatable

  enum role: { client: 'client', freelancer: 'freelancer', manager: 'manager' }

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :goomps, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :joined_goomps, through: :memberships, class_name: "Goomp", source: :goomp
  has_many :posts_from_joined_goomps, through: :joined_goomps, source: :posts
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :unseen_messages, dependent: :destroy

  has_many :rooms, dependent: :destroy
  has_many :slack_channels, dependent: :destroy
  has_many :managed_rooms, dependent: :destroy, class_name: "Room", foreign_key: :manager_id
  has_many :messages, dependent: :destroy

  before_save :ensure_authentication_token

  def joined_rooms
    Room.where("user_id = ? OR manager_id = ?", self.id, self.id).order("created_at desc")
  end

  validates :first_name, :last_name, :picture, :headline, presence: true

  extend FriendlyId
  friendly_id :full_name, use: :slugged


  def is_manager_of? goomp
    goomp.user == self
  end

  def manager?
    self.role == 'manager' || self.email == 'manager@goomp.co'
  end

  def client?
    !manager? && (self.role == 'client' || self.role.blank?)
  end

  def type
    return 'client'   if client?
    return 'manager'  if manager?
  end

  def online?
    return false if last_seen_at.nil?
    last_seen_at > 10.minutes.ago
  end

  def offline?
    !online?
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def first_name_for_email
    manager? ? 'Kriya Bot' : first_name
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
    if authdata[:provider] == 'twitter'
      if !auth.nil? && !auth.user.nil? && auth.user.persisted?
        return auth.user
      end
    else
      if auth.nil? || auth.user.nil?
        user = User.find_by email: authdata[:email]
        if !user.nil? && user.persisted?
          user.authorizations.create!(
            uid: authdata[:uid],
            provider: authdata[:provider],
            token: authdata[:token],
            refresh_token: authdata[:refresh_token]
            # expires_at: authdata["expires_at"],
          )
          return user
        end
      end
    end
    return auth&.user || authdata
  end

  private

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end
  end
end
