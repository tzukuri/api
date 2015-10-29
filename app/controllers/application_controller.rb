class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    acts_as_token_authentication_handler_for User

    def current_ability
        @current_ability ||= Ability.new(current_user, current_admin_user)
    end

    rescue_from CanCan::AccessDenied do |exception|
        respond_to do |format|
            format.json { render nothing: true, status: :forbidden }
            format.html { redirect_to '/', alert: exception.message }
        end
    end
end
