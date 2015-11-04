class Api::V0::UsersController < Api::ApiController
    def create
        # ensure the requesting app exists
        app_token = request.headers['X-tzu-app-token']
        render_error(:unknown_app, status: 404) if app_token.nil?
        @app = App.find_by_token_id(app_token)
        render_error(:unknown_app, status: 404) if @app.nil?

        # and ensure a device token id is provided. this device
        # may not exist yet, so a lookup isn't required
        api_device_token_id = params[:api_device_token_id]
        render_error(:unknown_api_device, status: 404) if api_device_token_id.nil?
        @api_device = ApiDevice.find_by_token_id(api_device_token_id)

        # attempt to create a new user record, any validation
        # errors will exit the response early
        User.create!(params.permit(:name, :email, :password))

        # after successfully creating a new user, create a new
        # record for their device if needed
        if @api_device.nil?
            @api_device = ApiDevice.create!(token_id: api_device_token_id)
        end
        
        # generate a new token
        @token = AuthToken.create_for!(user: @user, app: @app, api_device: @api_device)
    end

    def show
    end

    def update
    end
end
