class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # removing redirects for now, successful login will not redirect
    # to the correct dashboard path

    before_action :set_raven_extra_context

    private
      def set_raven_extra_context
        Raven.extra_context(params: params.to_unsafe_h, url: request.url)
      end
end
