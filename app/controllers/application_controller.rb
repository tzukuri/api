class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # todo: may be a better way to define sign in and out paths
    # override sign out paths
    def after_sign_out_path_for(resource_or_scope)
      case resource_or_scope

        # redirect to dashboard after user logout
        when :user, User
          '/dashboard'

        # redirect to beta/:invite_token after beta_user logout
        when :beta_user, BetaUser
          request.referrer

      end
    end

    # override sign in paths
    def after_sign_in_path_for(resource_or_scope)
      case resource_or_scope

        # redirect to dashboard after use login
        when :user, User
          '/dashboard'

        # redirect to beta/:invite_token after beta_user login
        when :beta_user, BetaUser
          request.referrer

      end
    end
end
