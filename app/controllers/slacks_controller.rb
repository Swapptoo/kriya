class SlacksController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def incoming
    if params[:challenge] && params[:type] == 'url_verification'
      render json: { challenge: params[:challenge] }, status: :ok
    else
      SlackEventsHandlerWorkerSyncWorker.perform_async(params.to_unsafe_h)
    end
  end
end
