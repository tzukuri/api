class Api::V0::RoomsController < Api::ApiController
  before_action :log_in_with_auth_token

  def index
    @rooms = @user.quietzones.find(params[:quietzone_id]).rooms
  end

  def create
    @room = Room.new(params.permit(:name))
    @room.quietzone_id = params[:quietzone_id]
    @room.save!
  end

  def show
    @room = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])
  end

  def update
    @room = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])
    @room.update!(params.permit(:name))
    @room.save!
  end

  def destroy
    @room = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])
    @room.delete
  end

end
