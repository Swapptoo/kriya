# == Schema Information
#
# Table name: payments
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  freelancer_id :integer
#
# Indexes
#
#  index_payments_on_freelancer_id  (freelancer_id)
#  index_payments_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_081dc04a02  (user_id => users.id)
#  fk_rails_af4664d870  (freelancer_id => freelancers.id)
#

class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :freelancer
end
