class PagesController < ApplicationController
    def index
        @html_klass = params[:page]
        @page_title = params[:page].titleize unless params[:page] == 'index'

        # if the store should apply a $100 discount (only used on reservation)
        @discount = params[:code] == "😎"
        @code = params[:code]

        begin
            render action: params[:page]
        rescue ActionView::MissingTemplate
            raise ActionController::RoutingError.new('')
        end
    end
end
