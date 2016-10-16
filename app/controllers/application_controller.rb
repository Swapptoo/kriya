class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  acts_as_token_authentication_handler_for User, fallback: :none

  before_action do
    if current_user && current_user.email == "cqpanxu@gmail.com"
      Rack::MiniProfiler.authorize_request
    end

    if user_signed_in? && (session[:last_seen_at] == nil || session[:last_seen_at] < 10.minutes.ago)
      current_user.update_attribute(:last_seen_at, Time.now)
      session[:last_seen_at] = Time.now
    end

  end

  def authenticate!
    return user_signed_in? || freelancer_signed_in?
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
      profile_attributes
    )
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:email, :password, :password_confirmation, :unsername, :bio, :first_name, :last_name, :picture, :headline, :work_experience, :gender)
    end
    devise_parameter_sanitizer.permit(:sign_up) do |freelancer|
      freelancer.permit(:email, :password, :password_confirmation, :unsername, :bio, :first_name, :last_name, :picture, :headline, :work_experience, :gender, :category, :availability, :primary_skill, :years_of_experiences, :project_description, :project_url, :professional_profile_link1, :professional_profile_link2, skill_ids: [])
    end
  end

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    root_path
  end
end
