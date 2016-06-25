require 'set'

class BetaController < ApplicationController
  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:list, :count, :graph]

  def index
    @token = params[:token]

    if beta_user_signed_in?
      @beta_user = current_beta_user
      @rank = @beta_user.rank
      @score_diff = 135 - @beta_user.score
      @invitees = @beta_user.invitees.count
      # @percentage_chance = @beta_user.percentage_chance
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

  def graph
    @people = Set.new

    @connections = BetaReferral.all.collect do |r|
      next unless r.inviter.present? && r.invitee.present?

      inviter = [r.inviter.id, r.inviter.name.gsub("'", "")]
      invitee = [r.invitee.id, r.invitee.name.gsub("'", "")]

      @people << inviter
      @people << invitee
      [inviter.first, invitee.first]
    end.compact

    @people = @people.to_a
  end

end
