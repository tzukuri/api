class BetaUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def instagram
    generic_callback('instagram')
  end

  def facebook
    generic_callback('facebook')
  end

  def twitter
    generic_callback('twitter')
  end

  def generic_callback(provider)
    # create or find an identity for the oauth object that we recieved
    @identity = BetaIdentity.find_for_oauth env["omniauth.auth"]

    # pull out a reference to this identity's user and connect the two
    @beta_user = @identity.beta_user || current_beta_user
    @identity.update_attribute( :beta_user_id, @beta_user.id )

    @beta_user.update_score

    redirect_to beta_user_path(@beta_user.invite_token)
  end

  def oauth_failure
    redirect_to beta_user_path current_beta_user.invite_token
  end
end
