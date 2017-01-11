class WelcomeEmailAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :unseen_message_alert, backtrace: true

  # Alert user if there're new unseen messages
  def perform(user_id)
    @recipient = User.find(user_id)

    unless @recipient.blank?
      UserNotifierMailer.notify_welcome_email(@recipient).deliver_now
      WelcomeFollowUpAlertWorker.perform_in(1.days, user_id)
    end

  end
end