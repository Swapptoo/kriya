class SlacksController < ApplicationController
  before_action :authenticate_user!

  def incoming
    if params[:challenge] && params[:type] == 'url_verification'
      render json: { challenge: params[:challenge] }, status: :ok
    else
      puts params
    end
  end
end
