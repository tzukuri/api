class PagesController < ApplicationController
    def index
        @html_klass = params[:page]
        @page_title = params[:page].titleize unless params[:page] == 'index'
        render action: params[:page]
    end
end
