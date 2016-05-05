class BetaSignupsController < ApplicationController

  def create
    if params[:beta_signup][:email].empty?
      render json: {success: false, errors: {email: ["is empty"]}}
      return
    end

    beta_signup = BetaSignup.create(email: params[:beta_signup][:email], country: params[:beta_signup][:country])

    if !beta_signup.valid?
      render :json => {success: false, errors: beta_signup.errors}
      return
    end

    # if an invite code is provided, this user has been invited by another
    if invite_code = params[:beta_signup][:invited_by]
      invited_by = BetaSignup.find_by_invite_code(invite_code)
      invited_by.invite(beta_signup)
    end

    if beta_signup.save
      render :json => {success: true, beta_signup: beta_signup}
    else
      render :json => {success: false, errors: beta_signup.errors}
    end

  end

end
