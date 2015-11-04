class Api::V0::AppParamsController < Api::ApiController
    before_action :log_in_with_auth_token
end
