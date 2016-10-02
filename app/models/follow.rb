# == Schema Information
#
# Table name: follows
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  followable_type :string
#  followable_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true, counter_cache: true
end
