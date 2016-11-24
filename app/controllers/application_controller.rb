class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # removing redirects for now, successful login will not redirect
    # to the correct dashboard path

    def after_sign_out_path_for(resource_or_scope)
      case resource_or_scope
        when :beta_user, BetaUser
          beta_user_redirect_path
        when :admin_user, AdminUser
          admin_root_path
      end
    end

    # override sign in paths
    def after_sign_in_path_for(resource_or_scope)
      case resource_or_scope
        when :beta_user, BetaUser
          beta_user_redirect_path
        when :admin_user, AdminUser
          admin_dashboard_path
      end
    end
end
