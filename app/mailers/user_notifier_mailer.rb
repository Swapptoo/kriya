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

  def notify_room_manager(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.manager
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
    @messages = messages.map { |msg| "#{full_name}: #{msg.body}" }
    messages.update_all(seen: true)

    mail(
      :to => user.email,
      :subject => "[Project] #{room.title}",
      :from => "room-" + room.id.to_s + "@messages.kriya.ai"
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
