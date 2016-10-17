# == Schema Information
#
# Table name: authorizations
#
#  id            :integer          not null, primary key
#  provider      :string
#  uid           :string
#  token         :string
#  refresh_token :string
#  expires_at    :datetime
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  freelancer_id :integer
#
# Indexes
#
#  index_authorizations_on_freelancer_id  (freelancer_id)
#  index_authorizations_on_provider       (provider)
#  index_authorizations_on_uid            (uid)
#  index_authorizations_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_4ecef5b8c5  (user_id => users.id)
#  fk_rails_70b5c75a6f  (freelancer_id => freelancers.id)
#

class Authorization < ApplicationRecord
  belongs_to :user
  validates :uid, :provider, presence: true
end
