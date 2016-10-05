class PagesController < ApplicationController
  def index
    if user_signed_in?
      if current_user.rooms.first
        redirect_to current_user.rooms.last
      else
        render "dashboard", layout: "application"
      end
    else
      session["new_user_role"] = 0
      render "index"
    end
  end

  def network
    if user_signed_in?
      if current_user.rooms.first
        redirect_to current_user.rooms.last
      else
        render "dashboard", layout: "application"
      end
    else
      session["new_user_role"] = 1
      render "network"
    end
  end
end
