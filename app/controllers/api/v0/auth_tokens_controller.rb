class Api::V0::AuthTokensController < Api::ApiController
    before_action :log_in_with_auth_token, only: :delete

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

        # lookup user by email
        email = params[:email]
        render_error(:unknown_email, status: 404) if email.nil?
        @user = User.find_by_email(email)
        render_error(:unknown_email, status: 404) if @user.nil?

        # return an error if this account is locked
        render_error(:account_locked, status: 423) if @user.access_locked?

        # confirm credentials
        render_error(:invalid_password) unless @user.valid_password?(params[:password])

        # return an existing token if the user has already
        # authenticated with this app and device
        unless @api_device.nil?
            @token = AuthToken.active_token_for(user: @user, app: @app, api_device: @api_device)
            return render(action: 'create') unless @token.nil?
        else
            @api_device = ApiDevice.create!(token_id: api_device_token_id)
        end

        # generate a new token
        @token = AuthToken.create_for!(user: @user, app: @app, api_device: @api_device)
    end

    def delete
        @token.revoke!(reason: 'API')
        render_success
    end
end
