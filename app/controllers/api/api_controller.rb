require 'base64'

class Api::ApiController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_filter :prevent_caching
    include ResponseRendering

    def prevent_caching
        response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end

    def log_in_with_auth_token
        # ensure nonce is unused
        nonce = request.headers['X-tzu-nonce']
        render_error(:invalid_token) if nonce.nil?

        # lookup app
        app_token = request.headers['X-tzu-app-token']
        Rails.logger.info("Request app token: '#{app_token}'")
        render_error(:unknown_app, status: 404) if app_token.nil?
        @app = App.find_by_token_id(app_token)
        render_error(:unknown_app, status: 404) if @app.nil?

        # decrypt the user token
        base64_token = request.headers['X-tzu-user-token']
        render_error(:invalid_token) if base64_token.nil?

        begin
            encrypted_token = Base64.decode64(base64_token)
        rescue RuntimeError
            render_error(:invalid_token)
        end

        begin
            decryption_password = nonce + @app.private_key
            decrypted_token = RubyRNCryptor.decrypt(
                encrypted_token,
                decryption_password
            )
            Rails.logger.info("Request auth token: '#{decrypted_token}'")
        rescue RuntimeError
            render_error(:invalid_token)
        end

        # lookup the token and ensure it's active
        @token = AuthToken.find_by_token(decrypted_token)
        render_error(:invalid_token) if @token.nil? || @token.revoked?

        # return an error if this account is locked
        render_error(:account_locked, status: 423) if @token.user.access_locked?

        # "log the user in" by retrieving the user record
        @user = @token.user
        Appsignal.tag_request(
            user: @user.id,
            auth_token: @token.id
        )
    end
end
