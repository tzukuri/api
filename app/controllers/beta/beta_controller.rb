class BetaController < ApplicationController

  def index
    @token = params[:token]

    if beta_user_signed_in?
      @beta_user = current_beta_user
      @percentage_chance = @beta_user.percentage_chance
      @answerable_questions = @beta_user.answerable_questions
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

  def forgot
    redirect_to beta_user_path(current_beta_user.invite_token) if beta_user_signed_in?
  end

  def retrieve
    beta_user = BetaUser.find_by(email: params[:email])

    beta_user.resend_link if !beta_user.nil?

    render :json => {success: true, email: params[:email]}
  end

end
