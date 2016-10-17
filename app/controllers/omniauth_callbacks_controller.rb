class OmniauthCallbacksController < ApplicationController
  [:facebook, :twitter, :linkedin].each do |provider|
    define_method provider do
      from_omniauth = Freelancer.from_omniauth(request.env["omniauth.auth"])

      if from_omniauth.is_a?(Freelancer) && from_omniauth.persisted?
        sign_in_and_redirect from_omniauth, event: :authentication #this will throw if from_omniauth is not activated
        # set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
      else
        session["devise.oauth_data"] = from_omniauth
        redirect_to new_freelancer_registration_url
      end
    end
  end

  def failure
    redirect_to root_path
  end
end