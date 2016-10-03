require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ['kriya', 'Q1p2m3g4']
end

Sidekiq.configure_server do |config|
  config.redis = { :url => Rails.application.secrets.redis_url, namespace: 'kriya', size: 25 }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => Rails.application.secrets.redis_url, namespace: 'kriya', size: 5 }
end
