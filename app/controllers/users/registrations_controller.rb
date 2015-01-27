class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  respond_to :html, :json

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
      flash.delete :recaptcha_error
      render :new
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:full_name, :username,
        :email, :password, :password_confirmation, :college)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:full_name, :username,
        :email, :password, :password_confirmation, :current_password, :college)
    end
  end

end
