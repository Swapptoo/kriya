namespace :message do
  desc 'Send email alert user with unseen message.'
  task unseen_alert: :environment do
    Room.find_each do |room|
      UnseenMessageAlertWorker.perform_async(room.id, room.manager_id) if room.notify_manager?
      UnseenMessageAlertWorker.perform_async(room.id, room.user_id) if room.notify_user?
    end
  end
end
