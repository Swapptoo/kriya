require_relative 'boot'

require 'rails/all'
require 'rails-observers'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dantos
  class Application < Rails::Application
    config.generators do |g|
      # g.assets false
      g.javascripts true
      g.stylesheets true
      g.stylesheet_engine :sass

      config.autoload_paths += %W(#{config.root}/app/observers #{config.root}/app/workers)

      config.active_record.observers   ||= []
      config.active_record.observers    += [
        :'room_observer',
        :'message_observer'
      ]
    end
  end
end
