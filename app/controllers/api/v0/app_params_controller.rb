class Api::V0::AppParamsController < Api::ApiController
    def show
        Rails.logger.info("Request device ID: '#{params['api_device_token_id']}'")
    end
end
