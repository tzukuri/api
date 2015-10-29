class V0::OwnershipsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    load_and_authorize_resource

    def index
        # ensure @ownserships joins devices
        @devices = @ownerships.map(&:device)
    end

    def create
        p @ownership
        return
        device = Device.find_by_mac_address(params[:mac_address])
        return render nothing: true, status: :forbidden if device.current_owner.exists?
        Ownership.create(device_id: device.id, user_id: current_user.id)
        render nothing: true
    end

    def destroy
        @ownership.revoked = Time.now.utc
        @ownership.reason = 'API'
        @ownership.save
        render nothing: true
    end
end
