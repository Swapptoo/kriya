require 'sendgrid_credential_helper'

class UserNotifierMailer < ApplicationMailer
  include SendGrid
  include SendgridCredentialHelper

  self.default_options = {
    :'X-SMTPAPI' => proc { disable_sendgrid_subscription_header },
    :from => 'Kriya Task <bot@kriya.ai>'
  }

  FROM_RAVI = 'Ravi Vadrevu <ravi@kriya.ai>'
  FROM_GREG = 'Greg Wisenberg <greg@kriya.ai>'


  def notify_room_user(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room

    mail(:to => @user.email, :subject => "#{room.title}")
  end


  def notify_welcome_email(user)
    @user = user
    @sendgrid_category = "Welcome Email"
    mail(:from => FROM_RAVI, :to => user.email, :subject => 'Welcome to the future of work!')

  end

  def notify_welcome_follow_up_email(user)
    @user = user
    @sendgrid_category = "Welcome Email Follow Up"
    mail(:from => FROM_GREG, :to => user.email, :subject => 'Your Kriya Task')

  end

  def notify_goomp(room)
    @sendgrid_category = "Room #{room.id}"
    @user = room.user
    @room = room
    @manager = room.manager

    mail(:to => 'manager@kriya.ai', :subject => "#{room.title}")

  end

  def notify_manager_on_first_escrow(room, amount)
    @sendgrid_category = "First Escrow on Room #{room.id}"
    @user = room.user
    @room = room
    @amount = amount / 100 #in dollars
    @manager = room.manager
    mail(:to => 'manager@kriya.ai', :subject => "First Escrow of USD#{@amount} for #{room.title}")

  end

  def notify_unseen_messages(room, recipient, messages)
    @sendgrid_category = "Room #{room.id}"
    @room = room
    @user = recipient
    @messages = []
    from = "Kriya Task <task-#{room.id}@messages.kriya.ai>"

    messages.each do |msg|
      next if msg.owner.nil?

      if msg.image.file.present?
        @messages << ['file', msg.owner.first_name_for_email, msg.image]
      elsif msg.body.present?
        @messages << ['text', msg.owner.first_name_for_email, msg.body]
      end
    end

    mail(to: @user.email, subject: room.title, from: from)
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
