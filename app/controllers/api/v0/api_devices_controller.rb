class Api::V0::ApiDevicesController < Api::ApiController
    before_action :log_in_with_auth_token

    def update
        @api_device = ApiDevice.find_by_token_id(params[:id])
        render_error(:unknown_api_device, status: 404) if @api_device.nil?

        @api_device.update!(params.permit(
            :launch_language, :preferred_language,
            :locale, :name, :os, :device_type
        ))

        token_changes = {}
        unless params[:app_version].nil?
            token_changes[:app_version] = params[:app_version]
        end
        unless params[:apns_token].nil?
           token_changes[:apns_token] = params[:apns_token]
        end 

        @token.update!(token_changes)
        render_success
    end
end
