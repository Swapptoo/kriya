# == Schema Information
#
# Table name: freelancer_authorizations
#
#  id            :integer          not null, primary key
#  provider      :string
#  uid           :string
#  token         :string
#  refresh_token :string
#  expires_at    :datetime
#  freelancer_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_freelancer_authorizations_on_freelancer_id  (freelancer_id)
#  index_freelancer_authorizations_on_provider       (provider)
#  index_freelancer_authorizations_on_uid            (uid)
#
# Foreign Keys
#
#  fk_rails_25ae8484b1  (freelancer_id => freelancers.id)
#


class FreelancerAuthorization < ApplicationRecord
  belongs_to :freelancer
  validates :uid, :provider, presence: true
end
