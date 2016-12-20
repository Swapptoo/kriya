class OmniauthCallbacksController < ApplicationController
  def create
    if params[:provider] == 'slack'
      code = params[:code]
      room_id = session.delete(:room_id)

      url = "https://slack.com/api/oauth.access?code=#{code}&client_secret=#{Rails.application.secrets.slack_app_secret}&client_id=#{Rails.application.secrets.slack_app_id}"
      response = HTTParty.get(url)

      if response['ok']
        token = response['access_token']
        scope = response['scope']
        uid  = response['user_id']
        team_name = response['team_name']
        team_id   = response['team_id']

        user = if user_signed_in?
          current_user
        else freelancer_signed_in?
          current_freelancer
        end

        room = Room.find_by(id: room_id)

        if room.present?
          slack_channel = user.slack_channels.find_or_initialize_by(room: room)

          slack_channel.assign_attributes(
            team_id: team_id,
            uid: uid,
            token: token,
            team_name: team_name,
            scope: scope
          )

          slack_channel.active!
          slack_channel.save

          #create channel
          client = Slack::Web::Client.new token: slack_channel.token

          channels = client.groups_list.groups

          channel = channels.detect { |c| slack_channel.channel_id == c.id || c.name == room.channel_name }

          if channel.nil?
            channel = client.groups_create(name: room.channel_name)
            slack_channel.update(channel_id: channel.group.id)
            client.chat_postMessage(channel: channel.group.id, text: "Thanks for creating a task on Kriya, you can track and communicate using this Slack channel.")
            message = client.chat_postMessage(channel: channel.group.id, text: "Keep this link to the Kriya room #{room.posts.first.public_url}")
            client.pins_add(channel: channel.group.id, timestamp: message.ts)
          else
            slack_channel.update(channel_id: channel.id)
          end

          slack_msg = room.messages.find_or_create_by(body: 'Thanks for that. One last question. Do you use Slack? Please click yes if you do as we deeply integrate with Slack to increase your productivity and communicate easily with the Kriya workforce.', user: room.manager, msg_type: "slack-#{user.type}")
          slack_msg.attachment.try(:destroy)
          slack_msg.create_attachment(:message => slack_msg, :html => "<br/>#{view_context.link_to 'Add Slack', '#', :class => 'mini ui green button custom-padding slack'}")

          room.messages.find_or_create_by(user: room.manager, msg_type: 'bot', body: "Integrated with Slack is successful, your channel name on Slack - #{room.channel_name}.")


        elsif freelancer_signed_in?
          # freelancer integrate slack afer sign up
          slack_channel = current_freelancer.slack_channels.find_or_initialize_by(room_id: nil)

          slack_channel.assign_attributes(
            team_id: team_id,
            uid: uid,
            token: token,
            team_name: team_name,
            scope: scope
          )

          slack_channel.save
          slack_channel.active!
        end

        flash[:notice] = 'Slack has been integrated successfully'
      else
        flash[:alert] = 'Fail to connect with slack'
      end

      if room_id.present?
        redirect_to room_path(room_id) and return
      else
        redirect_to root_path and return
      end
    end

    if request.env["omniauth.auth"]["provider"] == :stripe_connect
      current_freelancer.update_attributes(
        :stripe_publishable_key => request.env["omniauth.auth"]["info"]["stripe_publishable_key"],
        :stripe_token => request.env["omniauth.auth"]["credentials"]["token"],
        :stripe_client_id => request.env["omniauth.auth"]["uid"]
      )
      if request.env["omniauth.params"]["room_id"]
        room = Room.find request.env["omniauth.params"]["room_id"]
        message = room.messages.new({:body => 'Freelancer setup payment.', :room => room, :user => room.manager})
        message.save
        redirect_to room
      else
        redirect_to root_path
      end
    else
      if request.env["omniauth.params"]["user"] == "freelancer"
        from_omniauth = Freelancer.from_omniauth(request.env["omniauth.auth"])

        if from_omniauth.is_a?(Freelancer) && from_omniauth.persisted?
          sign_in_and_redirect from_omniauth, event: :authentication #this will throw if from_omniauth is not activated
          # set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
        else
          session["devise.oauth_data"] = from_omniauth
          redirect_to new_freelancer_registration_url
        end
      else
        from_omniauth = User.from_omniauth(request.env["omniauth.auth"])

        if from_omniauth.is_a?(User) && from_omniauth.persisted?
          sign_in_and_redirect from_omniauth, event: :authentication #this will throw if from_omniauth is not activated
          # set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
        else
          session["devise.oauth_data"] = from_omniauth
          redirect_to new_user_registration_url
        end
      end
    end
  end

  def failure
    redirect_to root_path
  end
end
