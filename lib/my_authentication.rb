module MyAuthentication
  class CustomStrategy < Devise::Strategies::Authenticatable

    # This check is run before +authenticate!+ is called to determine if this
    # authentication strategy is applicable. In this case we only try to authenticate
    # if the login and password are present
    #
    def valid?
      return email && invite_token
    end

    def authenticate!
      beta_user = BetaUser.find_by_invite_token(invite_token)

      if beta_user && invite_token == beta_user.invite_token && email == beta_user.email
        success! beta_user
      else
        fail! "Sorry, your email and invite combination is incorrect"
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

# for warden, `:my_authentication`` is just a name to identify the strategy
Warden::Strategies.add :my_authentication, MyAuthentication::CustomStrategy

# for devise, there must be a module named 'MyAuthentication' (name.to_s.classify), and then it looks to warden
# for that strategy. This strategy will only be enabled for models using devise and `:my_authentication` as an
# option in the `devise` class method within the model.
Devise.add_module :my_authentication, :strategy => true
