class BetaUser < ActiveRecord::Base
  devise :omniauthable, :registerable, :my_authentication
  has_many :beta_identities

  # beta referrals
  has_many :beta_referrals, :foreign_key => "inviter_id"
  has_many :invitees, :through => :beta_referrals

  before_validation :generate_invite_token, on: :create

  # validations
  validates :invite_token, presence: true

  # create a beta referral for this user
  def referred_by(referrer_token)
    BetaReferral.create(
      inviter_id: BetaUser.find_by_invite_token(referrer_token).id,
      invitee_id: self.id
    )
  end

  # ------------------
  # twitter
  # ------------------
  def twitter
    beta_identities.where(:provider => 'twitter').first
  end

  def twitter?
    beta_identities.where(:provider => 'twitter').exists?
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

  # ------------------
  # facebook
  # ------------------
  def facebook
    beta_identities.where(:provider => 'facebook').first
  end

  def facebook?
    beta_identities.where(:provider => 'facebook').exists?
  end

  def facebook_client
    if facebook?
      @facebook_client = Koala::Facebook::API.new(facebook.access_token)
    end
  end

  # ------------------
  # instagram
  # ------------------
  def instagram
    beta_identities.where(:provider => 'instagram').first
  end

  def instagram?
    beta_identities.where(:provider => 'instagram').exists?
  end

  def instagram_client
    if instagram?
      @instagram_client = Instagram.client(access_token: instagram.access_token)
    end
  end

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
      raise e, "Retried exhausted, could not find a unique token"
    end

end
