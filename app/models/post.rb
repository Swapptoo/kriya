# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  body             :text
#  comments_count   :integer
#  goomp_id         :integer
#  user_id          :integer
#  subtopic_id      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  title            :string
#  likes_count      :integer          default(0)
#  link_title       :string
#  link_url         :string
#  link_image       :string
#  link_description :string
#  content          :text
#  link_video       :string
#  token            :string
#
# Indexes
#
#  index_posts_on_goomp_id     (goomp_id)
#  index_posts_on_subtopic_id  (subtopic_id)
#  index_posts_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_164bf18369  (goomp_id => goomps.id)
#  fk_rails_5b5ddfd518  (user_id => users.id)
#  fk_rails_fd6c84fdf0  (subtopic_id => subtopics.id)
#

class Post < ApplicationRecord
  belongs_to :goomp, touch: true, counter_cache: true
  belongs_to :user, touch: true
  belongs_to :subtopic, optional: true, touch: true
  has_many :comments, dependent: :destroy
  has_one :message, dependent: :destroy
  has_one :room, through: :message

  validates :title, presence: true
  validate  :validate_content_from_editor

  before_save   :ensure_token
  after_commit  :trigger_room_notification, on: :create

  include Likable

  def generate_link_for_story!
    doc = Nokogiri::HTML(self.content)
    doc.css('.medium-insert-buttons').remove
    self.update(
      content: doc,
      link_description: Nokogiri::HTML(self.content).at_css("p").text,
      link_url: Rails.application.routes.url_helpers.post_path(self),
      link_title: self.title
    )
  end

  def content_escaped
    ActionView::Base.full_sanitizer.sanitize(content).gsub('+', '')
  end

  def short_title
    self.title.first(5)
  end

  def public_url
    Rails.application.routes.url_helpers.public_post_url(
      "#{short_title}-#{self.token}",
      host: Rails.application.secrets.host
    )
  end

  private

  def trigger_room_notification
    RoomWorker.perform_async(room.id) if room.present? && room.posts.count == 1
  end

  def validate_content_from_editor
    errors.add(:content, :blank) if content.blank? || content_escaped.match(/\A[a-zA-Z0-9]/).nil?
  end

  def ensure_token
    if token.blank?
      self.token = loop do
        token = Devise.friendly_token(6)
        break token unless Post.where(token: token).first
      end
    end
  end
end
