class BetaController < ApplicationController
  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:list, :count]

  def index
    @token = params[:token]

    if beta_user_signed_in?
      @beta_user = current_beta_user
      @percentage_chance = @beta_user.percentage_chance
      @answerable_questions = @beta_user.answerable_questions
      @email_hash = Digest::MD5.hexdigest @beta_user.email
    else
      # otherwise create an empty user and show the form
      if @token == 'invite'
        redirect_to '/'
      else
        @beta_user = BetaUser.new
      end
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

  # retrieve a users details and send an email
  def retrieve
    beta_user = BetaUser.find_by(email: params[:email])

    beta_user.resend_link if !beta_user.nil?

    render :json => {success: true}
  end

  def redirect
    if beta_user_signed_in?
      redirect_to beta_user_path current_beta_user.invite_token
    else
      redirect_to root_path
    end
  end

  # render CSV of a subset of attributes
  def list
      csv_string = CSV.generate do |csv|
        csv << ['name', 'email', 'score', 'birth_date', 'city']
        BetaUser.all.each do |betauser|
          csv << [betauser.name, betauser.email, betauser.score, betauser.birth_date, betauser.city]
        end
    end

    render body: csv_string
  end

  def count
    render body: BetaUser.count.to_s
  end

end
