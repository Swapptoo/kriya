# == Schema Information
#
# Table name: attachments
#
#  created_at :datetime         not null
#  html       :text
#  id         :integer          not null, primary key
#  message_id :integer
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attachments_on_message_id  (message_id)
#
# Foreign Keys
#
#  fk_rails_b804ba74cc  (message_id => messages.id)
#

class Attachment < ApplicationRecord
  belongs_to :message
  
  def select_pay_button
    self.html = <<~HTML.squish
        <p><button class="mini ui green button custom-padding" style="float:right">Pay</button></p><br/>
    HTML
    save  
  end
  
  def select_change_card_button
    self.html = <<~HTML.squish
        <p><button class="mini ui white button custom-padding" style="float:right">Change card</button></p><br/>
    HTML
    save 
  end
end
