require 'sendgrid_credential_helper'

class UserNotifierMailer < ApplicationMailer
  include SendGrid
  include SendgridCredentialHelper

  default 'X-SMTPAPI' => proc { disable_sendgrid_subscription_header }

  def notify_room_user(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user

    mail(:to => @user.email, :subject => "[Kriya] #{room.title}")
  end

  def notify_room_manager(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.manager

    mail(:to => @user.email, :subject => "[Kriya] #{room.title}")
  end

  def notify_unseen_message(message, user)
    @sendgrid_category = "Room #{message.room_id}"
    @user = user

    mail(
      :to => user.email,
      :subject => "[Kriya] #{message.room.title}",
      :body => message.body
    )
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
