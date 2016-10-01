# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  html       :text
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attachment < ApplicationRecord
  belongs_to :message
end
