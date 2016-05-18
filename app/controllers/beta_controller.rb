class BetaController < ApplicationController

  def index
    # authenticate_beta_user!
    @token = params[:token]

    # check for a token mismatch

    if beta_user_signed_in?
      # the user is signed in, so get the data for their details
      @beta_user = current_beta_user
      @rank = BetaUser.order(score: :desc).index(@beta_user)
    else
      # otherwise create an empty user and show the form
      @beta_user = BetaUser.new
    end
  end

  def invite
    @token = params[:token]

    if beta_user_signed_in?
      redirect_to "/beta/" + current_beta_user.invite_token
    end

    @beta_user = BetaUser.new
  end


end
