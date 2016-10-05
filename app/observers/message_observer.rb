class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    MessageWorker.perform_in(2.minutes, message.id)
  end
end
