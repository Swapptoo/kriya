require 'sendgrid_credential_helper'

class UserNotifierMailer < ApplicationMailer
  include SendGrid
  include SendgridCredentialHelper

  self.default_options = {
    :'X-SMTPAPI' => proc { disable_sendgrid_subscription_header },
    :from => 'Kriya Task <bot@kriya.ai>'
  }

  def notify_room_user(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room

    mail(:to => @user.email, :subject => "#{room.title}")
  end

  def notify_goomp(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room
    @manager = room.manager

    mail(:to => 'manager@goomp.co', :subject => "#{room.title}")
  end

  def notify_unseen_messages(room, sender, recipient, messages)
    @sendgrid_category = "Room #{room.id}"
    @room = room
    @user = recipient
    @messages = []

    full_name = sender.full_name
    user_type = 'client'
    user_type = 'freelancer' if room.accepted_freelancers.include?(sender)

    if sender == room.manager
      full_name = 'Kriya Task'
      user_type = 'manager'
    end

    from = "Kriya Task <#{user_type}-#{room.id}@messages.kriya.ai>"

    messages.each do |msg|
      if msg.image.file.present?
        @messages << ['file', full_name, msg.image]
      elsif msg.body.present?
        @messages << ['text', full_name, msg.body]
      end
    end

    mail(to: 'vibolteav@gmail.com', subject: room.title, from: from)
  end

  def notify_asigned_room(room, user)
    @sendgrid_category = "Room #{room.id}"
    @user = user
    @room = room
    mail(:to => @user.email, :subject => "#{room.title}")
  end

  private

  def disable_sendgrid_subscription_header
    smtp_api = {
      filters: {
        subscriptiontrack: {
          settings: {
            enable: 0
          }
        }
      },
      category: @sendgrid_category
    }

    headers['X-SMTPAPI'] = smtp_api.to_json
  end
end
