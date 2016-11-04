namespace :message do
  desc 'Send email alert user with unseen message.'
  task unseen_alert: :environment do
    Room.find_each do |room|
      UnseenMessageAlertWorker.new.perform(room.id, room.manager_id)
      UnseenMessageAlertWorker.new.perform(room.id, room.user_id)

      room.accepted_freelancers.each do |freelancer|
        UnseenMessageAlertWorker.new.perform(room.id, freelancer.id, :freelancer)
      end
    end
  end
end
