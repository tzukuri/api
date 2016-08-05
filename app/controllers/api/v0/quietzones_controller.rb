class Api::V0::QuietzonesController < Api::ApiController
    before_action :log_in_with_auth_token

    def index
        @quietzones = @user.quietzones
    end

    def create
        @quietzone = Quietzone.new(attrs)
        @quietzone.user_id = @user.id
        @quietzone.save!
    end

    def show
        @quietzone = @user.quietzones.find(params[:id])
    end

    def update
        @quietzone = @user.quietzones.find(params[:id])
        @quietzone.update!(attrs)
    end

    def destroy
        @deleted_quietzone = @user.quietzones.find(params[:id])
        @deleted_quietzone.destroy
    end

    private
        def attrs
            params.permit(:name, :latitude, :longitude, :radius,
                          :starttime, :endtime, :always_active)
        end
end
