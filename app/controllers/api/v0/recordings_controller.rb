class Api::V0::RecordingsController < Api::ApiController
  before_action :log_in_with_auth_token

  def index
    @recordings = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:room_id]).recordings
  end

  def create
    @recording = Recording.new(params.permit(:device_id, :recording_date, :data))
    @recording.room_id = params[:room_id]

    @recording.save!
  end

  def show
    @recording = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:room_id])
  end

  def update
    @recording = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:room_id])

    # only allowed to update data for the recording
    @recording.update!(params.permit(:data))

    @recording.save!
  end

  def destroy
    @recording = @user.quietzones.find(params[:quietzone_id]).rooms.find(params[:room_id])
    @recording.delete
  end

end
