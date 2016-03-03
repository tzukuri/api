class Api::V0::QuietzonesController < Api::ApiController

  def create
    log_in_with_auth_token

    # create a new quiet zone object
    @quietzone = Quietzone.new(params.permit(:name, :latitude, :longitude, :radius, :starttime, :endtime))
    @quietzone.user_id = @user.id

    # if this quietzone is not valid return an error with status 400
    render_error(:invalid_quietzone, status: 400) if @quietzone.invalid?

    # use @quietzone in the view to return the new object to the user
    @quietzone.save
  end

  def update
    log_in_with_auth_token

    # get the quiet zone that is being updated
    @quietzone = Quietzone.find(params[:id])

    # update the parameters with the user provided ones
    # the user can provide all or none of the parameters, they will only update if present
    @quietzone.name = params[:name]             if params[:name]
    @quietzone.latitude = params[:latitude]     if params[:latitude]
    @quietzone.longitude = params[:longitude]   if params[:longitude]
    @quietzone.radius = params[:radius]         if params[:radius]
    @quietzone.starttime = params[:starttime]   if params[:starttime]
    @quietzone.endtime = params[:endtime]       if params[:endtime]

    # if this quietzone is not valid return an error with status 400
    render_error(:invalid_quietzone, status: 400) if @quietzone.invalid?

    # save the quiet zone with the new data
    @quietzone.save

  end

  def delete

    log_in_with_auth_token

    # get the quiet zone that is being updated
    @quietzone = Quietzone.find(params[:id])

    @quietzone.delete

  end

end
