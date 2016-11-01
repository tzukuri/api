class DiagnosticsController < ApplicationController
    http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS"

    def index
        path = Rails.root.join('diagnostics')
        tokens = dir_entries(path)
        @auth_tokens = AuthToken.where(diagnostics_sync_token: tokens).all

        no_auth_path = path.join('NO_AUTH_TOKEN')
        @no_auth_tokens = dir_entries(no_auth_path)
    end

    def dates
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token])

        # try to access these dates, if it doesn't exist, try at NO_AUTH_TOKEN
        begin
          @dates = dir_entries(path)
        rescue
          no_auth_path = Rails.root.join('diagnostics', 'NO_AUTH_TOKEN', params[:token])
          @dates = dir_entries(no_auth_path)
        end

        @dates.sort!
    end

    def files
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token], params[:date])

        # try to access this file, if it doesn't exist, try at NO_AUTH_TOKEN
        begin
          @files = dir_entries(path)
        rescue
          no_auth_path = Rails.root.join('diagnostics', 'NO_AUTH_TOKEN', params[:token], params[:date])
          @files = dir_entries(no_auth_path)
        end

        @files.sort!
    end

    def show
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token], params[:date], params[:file])

        begin
          bytes = IO.binread(path)
        rescue
          no_auth_path = Rails.root.join('diagnostics', 'NO_AUTH_TOKEN', params[:token], params[:date], params[:file])
          bytes = IO.binread(no_auth_path)
        end

        io = StringIO.new(bytes)
        @blocks = []

        until io.eof?
            begin
                @blocks << Tzukuri::Block.new(io)
            rescue
                # ignore invalid blocks
            end
        end
    end

    private

    def dir_entries(path)
      Dir.entries(path) - ['.', '..', '.DS_Store']
    end
end
