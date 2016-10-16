# == Schema Information
#
# Table name: follows
#
#  created_at      :datetime         not null
#  followable_id   :integer
#  followable_type :string
#  id              :integer          not null, primary key
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_follows_on_followable_type_and_followable_id  (followable_type,followable_id)
#  index_follows_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_32479bd030  (user_id => users.id)
#

class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true, counter_cache: true
end
