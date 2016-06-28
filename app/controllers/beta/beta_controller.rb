require 'set'

class BetaController < ApplicationController
  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:list, :count, :graph]

  def index
    @token = params[:token]

    if beta_user_signed_in?
      @beta_user = current_beta_user

      # currently this calculates the threshold every time the user loads the index view
      # this is something that probably won't change all that often so calculating it on each page load
      # might be a waste. Leaving for the time being for simplicity.
      threshold_user = BetaUser.where("email NOT LIKE ? AND selected=false", "%@tzukuri.com%").order(score: :desc)[Tzukuri::NUM_THRESHOLD_USERS]

      # if the user does not exist, use a default threshold
      if threshold_user.nil?
        @threshold = Tzukuri::THRESHOLD_SCORE_DEFAULT
      else
        @threshold = threshold_user.score.to_i
      end

      @score_diff = @threshold - @beta_user.score
      @num_invitees = @beta_user.invitees.count
      @answerable_questions = @beta_user.answerable_questions
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
        BetaUser.order(created_at: :desc).each do |betauser|
          csv << [betauser.name, betauser.email, betauser.score, betauser.birth_date, betauser.city]
        end
    end

    render body: csv_string
  end

  def count
    render body: BetaUser.count.to_s
  end

  def list_order
    csv_string = CSV.generate do |csv|
        csv << ['name', 'email', 'score', 'birth_date', 'city']
        BetaUser.order(score: :desc).each do |betauser|
          csv << [betauser.name, betauser.email, betauser.score, betauser.birth_date, betauser.city]
        end
    end

    render body: csv_string
  end

  def process_referral(referral)
    return unless referral.inviter.present? && referral.invitee.present?
    @people << referral.inviter.graph_representation
    @people << referral.invitee.graph_representation
    @connections << [referral.inviter.id, referral.invitee.id]
  end

  def graph
    @people = Set.new
    @connections = []

    if params[:root].blank?
      # process all referrals
      BetaReferral.all.each {|referral| process_referral(referral)}

    else
      # fifo walk from the root referrer
      stack = BetaReferral.where(inviter_id: params[:root]).all.to_a
      until stack.empty?
        referral = stack.shift
        process_referral(referral)
        stack += BetaReferral.where(inviter_id: referral.invitee_id).all.to_a
      end
    end

    @all_people = BetaUser.all.collect {|user| user.graph_representation}
    @people = @people.to_a
  end

end
