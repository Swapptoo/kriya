class ApplicationMailer < ActionMailer::Base
  default :from => 'noreply@kriya.ai'
  self.default_url_options = { host: "#{Rails.application.secrets.host}:3000" }

  layout 'mailer'
end
