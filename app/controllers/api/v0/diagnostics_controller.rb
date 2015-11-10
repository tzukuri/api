require 'fileutils'

class Api::V0::DiagnosticsController < Api::ApiController
    def create
        # ensure the diagnostic token matches an auth token. these tokens
        # are used for this action (and this action only) because uploads
        # are managed by a background daemon on iOS. the OS may re-attempt
        # uploads and the normal auth scheme would reject these requests
        # because the nonce value wouldn't be unique. a special token
        # is used when uploads are performed and no user is logged into
        # the app. a device id is used to match the data to a user.
        token = params[:diagnostic_sync_token]
        Rails.logger.info("Request diagnostics token: '#{token}'")
        render_error(:invalid_token) if token.nil?

        date = params[:date]
        render_error(:invalid_diagnostics) if date.nil?

        file = env['rack.input']
        render_error(:invalid_diagnostics) if file.nil?
        
        file_name = params[:file_name]
        render_error(:invalid_diagnostics) if file_name.nil?

        if token == 'NO_AUTH_TOKEN'
            device_id = params[:device_id]
            render_error(:invalid_token) if device_id.nil?
            path = Rails.root.join('diagnostics', 'NO_AUTH_TOKEN', device_id, date, file_name)
        else
            auth_token = AuthToken.find_by_diagnostic_sync_token(token)
            render_error(:invalid_token) if auth_token.nil? || auth_token.revoked?
            path = Rails.root.join('diagnostics', token, date, file_name)
        end

        FileUtils.mkdir_p(File.dirname(path))
        open(path, 'w:ASCII-8BIT') do |f|
            f.write file.read
        end

        render_success
    end
end
