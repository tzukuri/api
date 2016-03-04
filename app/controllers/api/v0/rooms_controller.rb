class Api::V0::RoomsController < Api::ApiController

  # display a list of all rooms for the current quiet zone
  # GET /api/v0/quietzones/:quietzone_id/rooms
  def index
    # log the user in and get the @user object
    log_in_with_auth_token

    @rooms_for_quietzone = @user.quietzones.find(params[:quietzone_id]).rooms
  end

  # create a new room
  # POST /api/v0/quietzones/:quietzone_id/room
  def create
    # log the user in and get the @user object
    log_in_with_auth_token

    @quietzone = @user.quietzones.find(params[:quietzone_id])

    @room = Room.new(params.permit(:name))
    @room.quietzone_id = @quietzone.id

    render_error(:invalid_room, status: 400) if !@room.save
  end

  # display a specific room
  # GET /api/v0/quietzones/:quietzone_id/rooms/:id
  def show
    # log the user in and get the @user object
    log_in_with_auth_token

    @room = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])
  end

  # update a specific room
  # PATCH/PUT /api/v0/quietzones/:quietzone_id/rooms/:id
  def update
    # log the user in and get the @user object
    log_in_with_auth_token

    # get the quiet zone that we want to update
    @room_to_update = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])

    # update the parameters with the user provided ones
    # the user can provide all or none of the parameters, they will only update if present
    @room_to_update.name = params[:name]             if params[:name]

    render_error(:invalid_room, status: 400) if !@room_to_update.save
  end

  # delete a room
  # DELETE /api/v0/quietzones/:quietzone_id/rooms/:id
  def destroy
    # log the user in and get the @user object
    log_in_with_auth_token

    # get the quietzone with the param this is being updated and delete it
    @deleted_room = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:id])
    @deleted_room.delete
  end

  # ====================
  # UNUSED ACTIONS
  # =====================

  # return a HTML form for creating a new quietzone
  # GET /quietzones/new
  def new
  end

  # return a HTML form for editing a quiet zone
  # GET /quietzones/:id/edit
  def edit
  end

end
