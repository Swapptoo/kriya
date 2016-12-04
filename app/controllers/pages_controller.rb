class PagesController < ApplicationController
  before_action :set_room, if: :user_signed_in?

  def index
    session.delete(:room_id)

    if user_signed_in?
      if @room.present?
        redirect_to @room
      else
        render "dashboard", layout: "application"
      end
    elsif freelancer_signed_in?
      if current_freelancer.available_rooms.any?
        redirect_to current_freelancer.available_rooms.last and return
      else
        render "freelancer_dashboard", layout: "application"
      end
    else
      render "index"
    end
  end

  def network
    if user_signed_in?
      redirect_to root_path
    else
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
  end

  protected

  def set_room
    @room = current_user.joined_rooms.first
  end
end
