class BetaController < ApplicationController

  def index
    @token = params[:token]

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
    # if we're already authenticated redirect them to their details page
    redirect_to beta_user_path(current_beta_user.invite_token) if beta_user_signed_in?

    @token = params[:token]
    @invited_by = BetaUser.find_by(invite_token: @token)
    @beta_user = BetaUser.new

  end


end
