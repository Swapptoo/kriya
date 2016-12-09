class Payment::FirstEscrowWorker
  include Sidekiq::Worker
  sidekiq_options queue: :payment, backtrace: true

  def perform(id, amount)
    room = Room.find(id)

    UserNotifierMailer.notify_manager_on_first_escrow(room, amount).deliver_now
  end
end
