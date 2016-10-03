require_relative 'boot'

require 'rails/all'

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

      config.eager_load_paths += %W(#{config.root}/app/workers)
    end
  end
end
