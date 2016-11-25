class FreelancersController < ApplicationController
  before_action :authenticate_freelancer!

  def accept_kriya_policy
    respond_to do |format|
      format.js do
        current_freelancer.accept_kriya_policy!
      end
    end
  end

  def deny_slack
    slack_channel= current_freelancer.slack_channels.find_or_create_by(room_id: nil)
    slack_channel.inactive!

    redirect_to root_path
  end
end
