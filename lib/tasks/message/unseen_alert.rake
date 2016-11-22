namespace :message do
  desc 'Send email alert user with unseen message.'
  task unseen_alert: :environment do
    Room.find_each do |room|
      UnseenMessageAlertWorker.perform_async(room.id, room.manager_id)
      UnseenMessageAlertWorker.perform_async(room.id, room.user_id)

      room.in_progress_freelancers.each do |freelancer|
        UnseenMessageAlertWorker.perform_async(room.id, freelancer.id, :freelancer)
      end
    end
  end
end
