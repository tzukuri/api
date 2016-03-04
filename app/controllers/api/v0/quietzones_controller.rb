class Api::V0::QuietzonesController < Api::ApiController
  before_action :log_in_with_auth_token

  def index
    @quietzones = @user.quietzones
  end

  def create
    @quietzone = Quietzone.new(params.permit(:name, :latitude, :longitude, :radius, :starttime, :endtime))
    @quietzone.user_id = @user.id
    @quietzone.save!
  end

  def show
    @quietzone = @user.quietzones.find(params[:id])
  end

  def update
    @quietzone = @user.quietzones.find(params[:id])
    @quietzone.update!(params.permit(:name, :latitude, :longitude, :radius, :starttime, :endtime))
    @quietzone.save!
  end

  def destroy
    @deleted_quietzone = @user.quietzones.find(params[:id])
    @deleted_quietzone.delete
  end

end
