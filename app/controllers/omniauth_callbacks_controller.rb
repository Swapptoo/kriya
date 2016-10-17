class OmniauthCallbacksController < ApplicationController
  def create
    if request.env["omniauth.params"]["user"] == "freelancer"
      from_omniauth = Freelancer.from_omniauth(request.env["omniauth.auth"])

      if from_omniauth.is_a?(Freelancer) && from_omniauth.persisted?
        sign_in_and_redirect from_omniauth, event: :authentication #this will throw if from_omniauth is not activated
        # set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
      else
        session["devise.oauth_data"] = from_omniauth
        redirect_to new_freelancer_registration_url
      end
    else
      from_omniauth = User.from_omniauth(request.env["omniauth.auth"])

      if from_omniauth.is_a?(User) && from_omniauth.persisted?
        sign_in_and_redirect from_omniauth, event: :authentication #this will throw if from_omniauth is not activated
        # set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
      else
        session["devise.oauth_data"] = from_omniauth
        redirect_to new_user_registration_url
      end
    end
  end

  def failure
    redirect_to root_path
  end
end