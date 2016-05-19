class BetaUser < ActiveRecord::Base
  devise :omniauthable, :registerable, :beta_authable

  # record associations
  has_many  :identities,      :foreign_key => 'beta_user_id', :class_name => 'BetaIdentity'
  has_many  :responses,       :foreign_key => 'beta_user_id', :class_name => 'BetaResponse'
  has_many  :beta_referrals,  :foreign_key => 'inviter_id'
  has_many  :invitees,        :through => :beta_referrals

  # life cycle callbacks
  before_validation :generate_invite_token, on: :create
  after_create      :send_confirmation_email
  after_save        :check_for_selected

  # property validations
  validates :name,          presence: true
  validates :email,         presence: true,   uniqueness: true
  validates :invite_token,  presence: true,   uniqueness: true, :length => { :is => 6 }
  validates :score,         presence: true
  validates_format_of :email,:with => Devise.email_regexp

  # methods
  def referred_by(referrer_token)
    referred_by = BetaUser.find_by(invite_token: referrer_token)
    referred_by.update_score(1)
    BetaReferral.create(inviter_id: referred_by.id, invitee_id: self.id)
  end

  def unanswered_questions
    answered_ids = self.responses.map(&:beta_question_id)
    BetaQuestion.where.not(id: answered_ids)
  end

  def update_score(by_amount)
    self.score += by_amount
    self.save
  end

  # social methods
  def twitter
    identities.where(:provider => 'twitter').first
  end

  def twitter?
    identities.where(:provider => 'twitter').exists?
  end

  def twitter_client
    if twitter?
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "7EPMTuMvQz6isHz2PfACk5PZ4"
        config.consumer_secret     = "afywHMEak0vUDANUAX6iLqyoJ94sD9i3ACsDQZ7DfuZOkNRq0K"
        config.access_token        = twitter.access_token
        config.access_token_secret = twitter.private_token
      end
    end
  end

  def facebook
    identities.where(:provider => 'facebook').first
  end

  def facebook?
    identities.where(:provider => 'facebook').exists?
  end

  def facebook_client
    if facebook?
      @facebook_client = Koala::Facebook::API.new(facebook.access_token)
    end
  end

  def instagram
    identities.where(:provider => 'instagram').first
  end

  def instagram?
    identities.where(:provider => 'instagram').exists?
  end

  def instagram_client
    if instagram?
      @instagram_client = Instagram.client(access_token: instagram.access_token)
    end
  end

  # private methods
  private
    INVITE_CODE_LENGTH = 6
    INVITE_MAX_RETRIES = 5

    # generate an invite code of INVITE_CODE_LENGTH
    # will try up to INVITE_MAX_RETRIES times if a generated token is not unieq
    def generate_invite_token
      self.invite_token = Devise.friendly_token(INVITE_CODE_LENGTH)
    rescue ActiveRecord::RecordNotUnique => e
      @token_attempts = @token_attempts.to_i += 1
      retry if @token_attempts < INVITE_MAX_RETRIES
      raise e, "Retries exhausted, could not find a unique token"
    end

    # send the user a confirmation email
    def send_confirmation_email
      BetaMailer.send_beta_confirmation_email(self).deliver_later
    end

    # check if the user has been selected and send them an email alerting them of their status
    def check_for_selected
      if changes[:selected] && self.selected == true
        BetaMailer.send_beta_acceptance_email(self).deliver_later
      end
    end
end
