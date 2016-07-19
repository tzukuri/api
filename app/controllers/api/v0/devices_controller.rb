class Api::V0::DevicesController < Api::ApiController
    before_action :log_in_with_auth_token
    before_action :load_device, except: :index
    before_action :ensure_owner, except: [:index, :link]
    before_action :ensure_valid_ts, only: [:location, :connected, :disconnected]

    def index
        @devices = @user.devices
    end

    def show
    end

    def link
        unless @device.owner?(@user)
            render_error(:already_linked, status: 403) if @device.linked?
            if @device.pin_matches?(params[:pin])
                @device.link_to!(@user)
            else
                render_error(:invalid_pin)
            end
        end

        # when no errors, render the linked device information
        render action: 'show'
    end

    def unlink
        @device.unlink_from!(user: @user, reason: 'API')
        render_success
    end

    def location
        # ignore update if we have a newer location
        render_success if @device.coords_set_at.present? && (@ts < @device.coords_set_at)

        # ensure location data exists
        latitude = params[:lat]
        longitude = params[:lon]
        render_error(:invalid_coords) if latitude.nil? || longitude.nil?

        @device.update!(
            latitude: latitude.to_f,
            longitude: longitude.to_f,
            coords_set_at: @ts,
            coords_set_by_auth_token_id: @token.id
        )

        render_success
    end

    def connected
        # ignore update if we have a newer state
        render_success if @device.state_set_at.present? && (@ts < @device.state_set_at)
        @device.update!(
            state: Device.states[:connected],
            state_set_at: @ts,
            state_set_by_auth_token_id: @token.id
        )

        render_success
    end

    def disconnected
        # ignore update if we have a newer state
        render_success if @device.state_set_at.present? && (@ts < @device.state_set_at)
        @device.update!(
            state: Device.states[:disconnected],
            state_set_at: @ts,
            state_set_by_auth_token_id: @token.id
        )

        render_success
    end

    private
        def load_device
            @device = Device.find_by_serial(params[:id])
            render_error(:unknown_device, status: 404) if @device.nil?
        end

        def ensure_owner
            render_error(:not_owner, status: 403) unless @device.owner?(@user)
        end

        def ensure_valid_ts
            # ts is used to ignore the update if it was queued and is being
            # replayed but we already have newer data for the device
            @ts = params[:ts]
            render_error(:invalid_timestamp) if @ts.nil?

            @ts = @ts.to_i
            render_error(:invalid_timestamp) if @ts == 0
        end
end
