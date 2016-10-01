class RoomObserver < ActiveRecord::Observer
  def after_create(room)
    # Send mail
  end
end
