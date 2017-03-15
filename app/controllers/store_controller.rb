class StoreController < ApplicationController

  def show
    path = request.path.tr('/', '').split('-')

    @frame = path[0].capitalize
    @utility = path[1].capitalize

    if @utility == "Optical"
      @colour = "clear"
    else
      @colour = "brown"
    end
  end

end
