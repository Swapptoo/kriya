require 'sendgrid_credential_helper'

class UserNotifierMailer < ApplicationMailer
  include SendGrid
  include SendgridCredentialHelper

  self.default_options = {
    :'X-SMTPAPI' => proc { disable_sendgrid_subscription_header },
    :from => 'Kriya Bot <bot@kriya.ai>'
  }

  def notify_room_user(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room

    mail(:to => @user.email, :subject => "[Kriya] #{room.title}")
  end

  def notify_goomp(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room

    mail(:to => 'manager@goomp.co', :subject => "[Kriya] #{room.title}")
  end

  def notify_unseen_messages(room, user, other_user, messages)
    @sendgrid_category = "Room #{room.id}"
    @user = user
    @room = room
    full_name = other_user.full_name
    full_name = 'Kriya Bot' if other_user == room.manager
    @messages = []
	messages.each do |msg|
      if msg.image.file.present? then
	    @messages << ["file", full_name, msg.image]
	  else
	    @messages << ["text", full_name, msg.body]
	  end
	end
	print "#######################################"
	print messages.to_s
	messages.update_all(seen: true)
	if other_user == room.manager then
	  usertype = "manager"
	else
	  usertype = "client"
	end

    mail(
      :to => user.email,
      :subject => "[Task] #{room.title}",
      :from => "Kriya Notification <" + usertype + "-" + room.id.to_s + "@messages.kriya.ai>"
    )
  end

  def notify_asigned_room(room, user)
    @sendgrid_category = "Room #{room.id}"
    @user = user
    @room = room
    mail(:to => @user.email, :subject => "[Kriya] #{room.title}")
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
