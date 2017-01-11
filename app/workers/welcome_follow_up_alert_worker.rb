class WelcomeFollowUpAlertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :welcome_email_follow_up_alert, backtrace: true

  # Alert user if there're new unseen messages
  def perform(user_id)
    @recipient = User.find(user_id)

    unless @recipient.blank?
      UserNotifierMailer.notify_welcome_follow_up_email(@recipient).deliver_now
    end

  end
end