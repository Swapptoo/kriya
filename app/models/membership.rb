# == Schema Information
#
# Table name: memberships
#
#  created_at :datetime         not null
#  goomp_id   :integer
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_memberships_on_goomp_id              (goomp_id)
#  index_memberships_on_goomp_id_and_user_id  (goomp_id,user_id) UNIQUE
#  index_memberships_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_99326fb65d  (user_id => users.id)
#  fk_rails_e8af24f046  (goomp_id => goomps.id)
#

class Membership < ApplicationRecord
  belongs_to :goomp, counter_cache: true
  belongs_to :user

  validates :goomp_id, uniqueness: {scope: [:user_id]}
end
