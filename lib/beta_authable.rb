module BetaAuthable
  class BetaAuthenticationStrategy < Devise::Strategies::Authenticatable

    # if false the rest of authentication does not continue
    def valid?
      return email && invite_token
    end

    def authenticate!
      beta_user = BetaUser.find_by_invite_token(invite_token)

      if beta_user && invite_token == beta_user.invite_token && email == beta_user.email
        success! beta_user
      else
        fail! 'The email address you provided is incorrect'
      end
    end

    private

    def email
      (params[:beta_user] || {})[:email]
    end

    def invite_token
      (params[:beta_user] || {})[:invite_token]
    end
  end
end

# add module to devise and strategy to warden
Warden::Strategies.add :beta_authable, BetaAuthable::BetaAuthenticationStrategy
Devise.add_module :beta_authable, :strategy => true
