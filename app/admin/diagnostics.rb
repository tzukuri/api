ActiveAdmin.register_page "Diagnostics" do
  controller do

    # show a list of the authentication tokens
    def devices
      path = Rails.root.join('diagnostics')
      tokens = Dir.entries(path) - ['.', '..', 'NO_AUTH_TOKEN']
      @auth_tokens = AuthToken.where(diagnostics_sync_token: tokens).all

      # set the active admin page title
      @page_title = "Authentication Tokens"
    end

    # show a list of all the dates for an authentication token
    def dates
      @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
      path = Rails.root.join('diagnostics', params[:token])
      @dates = Dir.entries(path) - ['.', '..', '.DS_Store']
      @dates.sort!

      @file_count = {}

      @dates.each do |date|
        path = Rails.root.join('diagnostics', params[:token], date)
        files = Dir.entries(path) - ['.', '..', '.DS_Store']
        @file_count[date] = files.count
      end

      @page_title = "#{@auth_token.api_device.name}"
    end

    # list all the files for a given date
    def files
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])

        @data = Tzukuri::Diagnostics.entries_for_token_date(params[:token], params[:date],
            # whitelist entry types
            ['stateMachine', 'appEnvironment', 'notificationDisplayed', 'notificationScheduled', 'appDidBecomeActive', 'bleDisconnected', 'bleConnected'],
            # aggregate entry types (count)
            ['appDidBecomeActive', 'notificationDisplayed', 'bleDisconnected']
        )

        start_time = @data[:aggregates][:start_time].in_time_zone('Australia/Sydney')
        end_time = @data[:aggregates][:end_time].in_time_zone('Australia/Sydney')
        time = start_time

        @hours = []

        while time.hour != end_time.hour || time.day != end_time.day
          @hours << time.hour
          time = time.in(1.hour)
        end

        @page_title = "#{@auth_token.api_device.name} / #{params[:date]}"
    end

    def expand
      entries = Tzukuri::Diagnostics.entries_between_index(params[:token], params[:date], params[:start_index], params[:end_index])
      render json: {success: true, count: entries.count, entries: entries}
    end

  end
end