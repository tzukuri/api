module Tzukuri
  class BetaAuthable < Devise::Strategies::Authenticatable

    # This check is run before +authenticate!+ is called to determine if this
    # authentication strategy is applicable. In this case we only try to authenticate
    # if the login and password are present
    #
    def valid?
      puts "VALIDITY CHECK"
      return email && invite_token
    end

    def authenticate!
      puts "======AUTHENTICATING!======"
      # beta_user = BetaUser.find_by_invite_code(invite_token)

      # if beta_user && invite_token == beta_user.invite_code
      #   success! beta_user
      # else
      #   fail! "Sorry, your email/invite code combination is incorrect"
      # end
    end

    private

    def email
      (params[:beta_user] || {})[:email]
    end

    def invite_token
      (params[:beta_user] || {})[:invite_code]
    end
  end
end

# for warden, `:my_authentication`` is just a name to identify the strategy
Warden::Strategies.add :beta_authable, Tzukuri::BetaAuthable

# for devise, there must be a module named 'MyAuthentication' (name.to_s.classify), and then it looks to warden
# for that strategy. This strategy will only be enabled for models using devise and `:my_authentication` as an
# option in the `devise` class method within the model.
Devise.add_module :beta_authable, :strategy => true
