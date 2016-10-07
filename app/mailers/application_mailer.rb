class ApplicationMailer < ActionMailer::Base
  default :from => 'noreply@kriya.ai'
  self.default_url_options = { host: "#{Rails.application.secrets.host}" }

  layout 'mailer'
end
