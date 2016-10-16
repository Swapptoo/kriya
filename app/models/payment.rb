# == Schema Information
#
# Table name: payments
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_payments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_081dc04a02  (user_id => users.id)
#

class Payment < ApplicationRecord
  belongs_to :user
end
