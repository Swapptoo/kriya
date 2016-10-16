# == Schema Information
#
# Table name: authorizations
#
#  created_at    :datetime         not null
#  expires_at    :datetime
#  id            :integer          not null, primary key
#  provider      :string
#  refresh_token :string
#  token         :string
#  uid           :string
#  updated_at    :datetime         not null
#  user_id       :integer
#
# Indexes
#
#  index_authorizations_on_provider  (provider)
#  index_authorizations_on_uid       (uid)
#  index_authorizations_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_4ecef5b8c5  (user_id => users.id)
#

class Authorization < ApplicationRecord
  belongs_to :user
  validates :uid, :provider, presence: true
end
