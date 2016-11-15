Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.dsn = 'https://21f2d2d23d874187a5e3d76dac990ceb:9ac7b0843d60417cb57240bdb79f13a1@sentry.io/114610'
  config.environments = ['staging', 'production']
end