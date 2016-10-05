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
