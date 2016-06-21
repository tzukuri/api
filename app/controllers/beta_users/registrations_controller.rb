class BetaUsers::RegistrationsController < Devise::RegistrationsController

  def create
    puts sign_up_params
    build_resource(sign_up_params)
    resource.save

    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_up(resource_name, resource)

        # set up referral and assign points
        resource.referred_by(sign_up_params[:invite_token])
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      # store the error messages in flash and redirect to the invite path
      flash[:notice] = flash[:notice].to_a.concat resource.errors.full_messages
      redirect_to beta_user_invite_path(sign_up_params[:invite_token])
    end
  end

  private

  def sign_up_params
    params.require(:beta_user).permit(:email, :name, :invite_token, :birth_date, :latitude, :longitude, :city)
  end

end
