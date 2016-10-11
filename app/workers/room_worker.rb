class RoomWorker
  include Sidekiq::Worker
  sidekiq_options queue: :room, backtrace: true

  def perform(id)
    room = Room.find(id)
    UserNotifierMailer.notify_room_user(room).deliver_now
    UserNotifierMailer.notify_room_manager(room).deliver_now
  end
end
