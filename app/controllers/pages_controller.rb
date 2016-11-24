class PagesController < ApplicationController
    def index
        @html_klass = params[:page]
        @page_title = params[:page].titleize unless params[:page] == 'index'

        # if the store should apply a $100 discount (only used on reservation)
        @code = params[:code]
        @discount = 0
        
        if !@code.nil?
          @discount = Tzukuri::DISCOUNTS[@code.to_sym] || 0
        end

        begin
            render action: params[:page]
        rescue ActionView::MissingTemplate
            raise ActionController::RoutingError.new('')
        end
    end
end
