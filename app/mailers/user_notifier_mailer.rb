require 'sendgrid_credential_helper'

class UserNotifierMailer < ApplicationMailer
  include SendGrid
  include SendgridCredentialHelper

  def notify_room_user(room)
    headers "X-SMTPAPI" => {
      category: ["Task"]
    }.to_json

    mail(:to => room.user.email, :subject => 'Thanks for signing up for our amazing app')
  end

  def notify_room_manager(room)
    headers "X-SMTPAPI" => {
      category: ["Task"]
    }.to_json

    mail(:to => room.manager.email, :subject => 'Thanks for signing up for our amazing app')
  end

  def notify_unseen_message(message, user)
    puts user.email

    headers "X-SMTPAPI" => {
      category: ['Unseen Message']
    }.to_json

    mail(
      :to => user.email,
      :subject => "Here is what you've missed!",
      :body => message.body
    )
  end

end
