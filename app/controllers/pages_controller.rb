class PagesController < ApplicationController
    def index
        @html_klass = params[:page]
        @page_title = params[:page].titleize unless params[:page] == 'index'

        begin
            render action: params[:page]
        rescue ActionView::MissingTemplate
            raise ActionController::RoutingError.new('')
        end
    end
end
