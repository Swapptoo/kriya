# == Schema Information
#
# Table name: posts
#
#  body             :text
#  comments_count   :integer
#  content          :text
#  created_at       :datetime         not null
#  goomp_id         :integer
#  id               :integer          not null, primary key
#  likes_count      :integer          default(0)
#  link_description :string
#  link_image       :string
#  link_title       :string
#  link_url         :string
#  link_video       :string
#  subtopic_id      :integer
#  title            :string
#  updated_at       :datetime         not null
#  user_id          :integer
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

  after_commit :trigger_room_notification, on: :create

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

  private

  def trigger_room_notification
    RoomWorker.perform_async(room.id) if room.present? && room.posts.count == 1
  end
end
