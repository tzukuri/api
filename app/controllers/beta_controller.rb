class BetaController < ApplicationController

  def index
    # authenticate_beta_user!
    @token = params[:token]

    if beta_user_signed_in?
      # the user is signed in, so get the data for their details
      # @beta_user = BetaUser.find_by_invite_token(@token)
      @beta_user = current_beta_user
    else
      # otherwise create an empty user and show the form
      @beta_user = BetaUser.new()
    end
  end

  def invite
    @invite_code = params[:invite_code]
  end


end
