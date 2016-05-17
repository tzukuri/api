class BetaUsers::RegistrationsController < Devise::RegistrationsController
  def create
    super
    invited_by_token = params[:beta_user][:invite_token]

    # store the user agent on the beta user object
    resource.ip_address = request.remote_ip
    resource.user_agent = request.env["HTTP_USER_AGENT"]

    # if the resource is saved, create a referral record
    if resource.save
      BetaReferral.create_for(resource.id, invited_by_token)
    end
  end

  private

  def sign_up_params
    params.require(:beta_user).permit(:email, :name, :invite_token)
  end

  def account_update_params
    params.require(:beta_user).permit(:email, :name, :invite_token)
  end

end
