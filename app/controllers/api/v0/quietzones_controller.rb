class Api::V0::QuietzonesController < Api::ApiController

  # display a list of all quietzones for the current user
  # GET /quietzones
  def index
    # log the user in and get the @user object
    log_in_with_auth_token

    @quietzones_for_user = @user.quietzones
  end

  # create a new quietzone
  # POST /quietzones
  def create
    # log the user in and get the @user object
    log_in_with_auth_token

    # TODO: maybe make this shorter by using .require, etc
    # create a new quiet zone object
    @quietzone = Quietzone.new(params.permit(:name, :latitude, :longitude, :radius, :starttime, :endtime))
    @quietzone.user_id = @user.id

    render_error(:invalid_quietzone, status: 400) if !@quietzone.save
  end

  # display a specific quiet zone
  # GET /quietzones/:id
  def show
    # log the user in and get the @user object
    log_in_with_auth_token

    # find the quietzone with this id in the users quietzones
    @quietzone = @user.quietzones.find(params[:id])
  end

  # update a specific quiet zone
  # PATCH/PUT /quietzones/:id
  def update
    # log the user in and get the @user object
    log_in_with_auth_token

    # get the quiet zone that we want to update
    @quietzone_to_update = @user.quietzones.find(params[:id])

    # update the parameters with the user provided ones
    # the user can provide all or none of the parameters, they will only update if present
    @quietzone_to_update.name = params[:name]             if params[:name]
    @quietzone_to_update.latitude = params[:latitude]     if params[:latitude]
    @quietzone_to_update.longitude = params[:longitude]   if params[:longitude]
    @quietzone_to_update.radius = params[:radius]         if params[:radius]
    @quietzone_to_update.starttime = params[:starttime]   if params[:starttime]
    @quietzone_to_update.endtime = params[:endtime]       if params[:endtime]

    render_error(:invalid_quietzone, status: 400) if !@quietzone_to_update.save
  end

  # delete a quiet zone
  # DELETE /quietzones/:id
  def destroy
    # log the user in and get the @user object
    log_in_with_auth_token

    # get the quietzone with the param this is being updated and delete it
    @deleted_quietzone = @user.quietzones.find(params[:id])
    @deleted_quietzone.delete
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
