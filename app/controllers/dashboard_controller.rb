class DashboardController < ApplicationController

before_action :authenticate_user!

def index
  @current_user = current_user
  @device = @current_user.devices.first
end

end
