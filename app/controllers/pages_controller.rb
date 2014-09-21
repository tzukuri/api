class PagesController < ApplicationController
    def index
        @html_klass = params[:page]
        render action: params[:page]
    end
end
