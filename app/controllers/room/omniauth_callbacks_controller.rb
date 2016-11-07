class OmniauthCallbacksController < ApplicationController
  def create
    if params[:provider] == 'slack'
      code = params[:code]
      url = "https://slack.com/api/oauth.access?code=#{code}&client_secret=#{Rails.application.secrets.slack_app_secret}&client_id=#{Rails.application.secrets.slack_app_id}"
      response = HTTParty.get(url)

      if response['ok']
        rooms = []

        if current_user.present?
          current_user.authorizations.create(uid: response['user_id'], token: response['access_token'])
          rooms = current_user.rooms
        elsif current_freelancer.present?
          current_freelancer.authorizations.create(uid: response['user_id'], token: response['access_token'])
          rooms = current_freelancer.rooms
        end

        rooms.each do |room|
          channel_name = "kria.ai-#{room.title}"
          url = "https://slack.com/api/channels.create?token=#{response['access_token']}&name=#{channel_name}"
          response = HTTParty.get(url)
        end

      else
        flash[alert] = 'Fail to connect with slack'
      end
      redirect_to root_path
    end
  end
end
