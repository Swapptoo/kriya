class PagesController < ApplicationController
  def index
    if user_signed_in?
      if current_user.rooms.first
        redirect_to current_user.rooms.last
      else
        render "dashboard", layout: "application"
      end
    else
      session["new_user_role"] = 'client'
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
      session["new_user_role"] = 'freelancer'
      render "network"
    end
  end
end
