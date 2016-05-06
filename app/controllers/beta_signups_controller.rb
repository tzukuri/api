class BetaSignupsController < ApplicationController

  def create
    @beta_signup = BetaSignup.create(beta_signup_params)
    @invite_code = params[:beta_signup][:invited_by]

    if !@beta_signup.valid?
      render :json => {success: false, errors: @beta_signup.errors, error_messages: @beta_signup.errors.full_messages}
      return
    end

    # if an invite code is provided, this user has been invited by another
    # todo: potentially integrate this as part of the create process
    if @invite_code
      invited_by = BetaSignup.find_by_invite_code(@invite_code)
      invited_by.invite(@beta_signup)
    end

    if @beta_signup.save
      render :json => {success: true, beta_signup: @beta_signup}
    else
      render :json => {success: false, errors: @beta_signup.errors}
    end
  end

  private

  # required parameters out of the params object
  def beta_signup_params
    params.require(:beta_signup).permit(:name, :email, :country)
  end

end
