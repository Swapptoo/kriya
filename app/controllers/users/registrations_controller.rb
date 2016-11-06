class Users::RegistrationsController < Devise::RegistrationsController
# before_action :configure_sign_up_params, only: [:create]
# before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super do |user|
      authdata = session["devise.oauth_data"]
      if authdata
        user.first_name = authdata["first_name"]
        user.last_name = authdata["last_name"]
        user.picture = authdata["picture"]
        user.headline = authdata["headline"]
        user.email = authdata["email"]
        user.gender = "male"
      end
      @oauth = !authdata.nil?
    end
  end

  # POST /resource
  def create
    authdata = session["devise.oauth_data"]
    super do |user|
      if authdata
        resource.email ||= authdata["email"]
        resource.password = authdata["password"] || Devise.friendly_token[0,20]
      end

      resource.save

      if resource.persisted?

        if authdata
          resource.authorizations.create!(
            uid: authdata["uid"],
            provider: authdata["provider"],
            token: authdata["token"],
            refresh_token: authdata["refresh_token"]
            # expires_at: authdata["expires_at"],
          )
          session.delete("devise.oauth_data")
        end
      end

      @oauth = !authdata.nil?
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # rooms#create_room_from_sign_up
  def after_sign_up_path_for(resource)
    task_from_sign_up_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
