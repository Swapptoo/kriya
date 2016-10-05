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
#

class Authorization < ApplicationRecord
  belongs_to :user
  validates :uid, :provider, presence: true
end
