class DiagnosticsController < ApplicationController
    http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS"

    def index
        path = Rails.root.join('diagnostics')
        tokens = Dir.entries(path) - ['.', '..', 'NO_AUTH_TOKEN']
        @auth_tokens = AuthToken.where(diagnostics_sync_token: tokens).all
    end

    def dates
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token])
        @dates = Dir.entries(path) - ['.', '..']
        @dates.sort!
    end

    def files
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token], params[:date])
        @files = Dir.entries(path) - ['.', '..']
        @files.sort!
    end

    def show
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token], params[:date], params[:file])
        bytes = IO.binread(path)
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
    
end
