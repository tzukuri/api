class BetaUser < ActiveRecord::Base

  devise :omniauthable, :my_authentication

  has_many :beta_identities

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
end
