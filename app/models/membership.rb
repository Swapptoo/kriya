# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  goomp_id   :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Membership < ApplicationRecord
  belongs_to :goomp, counter_cache: true
  belongs_to :user

  validates :goomp_id, uniqueness: {scope: [:user_id]}
end
