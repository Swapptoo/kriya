class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action do
    if current_user && current_user.email == "cqpanxu@gmail.com"
      Rack::MiniProfiler.authorize_request
    end
  end

  def set_meta(options={})
    site_name   = "Goomp"
    title       = "Goomp"
    description = "Goomp is an exclusive member only group where creators share network, mentorship and premium content for free or a membership fee"
    image       = ActionController::Base.helpers.asset_path("logo-v.png")
    current_url = request.url
    keywords = %w[迅雷 bt 下载 网盘 高清 电影 动漫 日剧 美剧 天天 720p 1080p]

    # Let's prepare a nice set of defaults
    defaults = {
      site:        site_name,
      title:       title,
      reverse: true,
      separator: '-',
      image:       image,
      description: description,
      keywords:    keywords,
      twitter: {
        site_name: site_name,
        site: '@thecookieshq',
        card: 'summary',
        description: description,
        image: image
      },
      og: {
        url: current_url,
        site_name: site_name,
        title: title,
        image: image,
        description: description,
        type: 'website'
      }
    }

    options.reverse_merge!(defaults)

    @meta_tags = options
  end

  protected

  def configure_permitted_parameters
    keys = %i(
      username
      bio
      first_name
      last_name picture
      headline
      work_experience
      gender
    )
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
  end

end
