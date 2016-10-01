class RoomObserver < ActiveRecord::Observer
  def after_create(room)
    RoomWorker.perform_in(30.seconds, room.id)
  end
end
