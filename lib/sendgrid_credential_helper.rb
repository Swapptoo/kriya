module SendgridCredentialHelper
  def self.included(base)
    base.before_action :set_sendgrid_smtp_settings
  end

  protected

  def set_sendgrid_smtp_settings
    smtp_settings[:port]           = 587
    smtp_settings[:authentication] = :plain
    smtp_settings[:address]        = 'smtp.sendgrid.net'
    smtp_settings[:domain]         = Rails.application.secrets.sendgrid_domain
    smtp_settings[:password]       = Rails.application.secrets.sendgrid_password
    smtp_settings[:user_name]      = Rails.application.secrets.sendgrid_username
  end
end
