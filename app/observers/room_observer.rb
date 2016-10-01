class RoomObserver < ActiveRecord::Observer
  def after_create(room)
    RoomWorker.perform_async(room.id)
  end
end
