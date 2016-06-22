class BetaUsers::RegistrationsController < Devise::RegistrationsController

  def create
    puts sign_up_params
    build_resource(sign_up_params)
    resource.save

    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        resource.referred_by(sign_up_params[:invite_token])
      else
        expire_data_after_sign_in!
      end

      render :json => {
        success: true,
        redirectURL: beta_user_path(resource.invite_token)
      }

      return
    else
      render :json => {
        success: false,
        error_messages: resource.errors.full_messages,
        errors: resource.errors
      }
    end
  end

  private

  def sign_up_params
    params.require(:beta_user).permit(:email, :name, :invite_token, :birth_date, :latitude, :longitude, :city)
  end

end
