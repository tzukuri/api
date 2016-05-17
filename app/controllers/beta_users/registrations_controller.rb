class BetaUsers::RegistrationsController < Devise::RegistrationsController

  def new
    puts "NEW REGISTRATION!"
  end

  def create
    puts "CREATING NEW REGISTRATION!"
    super
    # store the user agent on the resource
    resource.ip_address = request.remote_ip
    resource.user_agent = request.env["HTTP_USER_AGENT"]

    # todo: link the resource for referral purposes
    # params[:beta_user][:invite_token]

    resource.save
  end

  private

  def sign_up_params
    params.require(:beta_user).permit(:email, :name, :invite_token)
  end

  def account_update_params
    params.require(:beta_user).permit(:email, :name, :invite_token)
  end

end
