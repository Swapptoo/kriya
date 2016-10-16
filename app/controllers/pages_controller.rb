class PagesController < ApplicationController
  before_action :set_room, if: :user_signed_in?

  def index
    if user_signed_in?
      if @room.present?
        redirect_to @room
      else
        render "dashboard", layout: "application"
      end
    elsif freelancer_signed_in?
      if current_freelancer.asigned_rooms.any?
        redirect_to current_freelancer.asigned_rooms.last
      else
        render "freelancer_dashboard", layout: "application"
      end
    else
      render "index"
    end
  end

  def network
    if freelancer_signed_in?
      if current_freelancer.rooms.first
        redirect_to current_user.rooms.last
      else
        render "dashboard", layout: "application"
      end
    else
      render "network"
    end
  end

  protected

  def set_room
    @room = current_user.joined_rooms.first
  end
end
