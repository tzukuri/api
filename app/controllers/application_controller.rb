class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # ensure that users are directed to the dashboard when signing in or out
    def after_sign_in_path_for(resource)
        "/dashboard"
    end
    def after_sign_out_path_for(resource)
        "/dashboard"
    end
end
