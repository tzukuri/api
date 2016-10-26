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
        # @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        # path = Rails.root.join('diagnostics', params[:token], params[:date])
        # @files = Dir.entries(path) - ['.', '..', '.DS_Store']
        # @files.sort!
        #
        # @all_files = {}
        #
        # @files.each do |file|
        #   file_path = Rails.root.join('diagnostics', params[:token], params[:date], file)
        #   @all_files[file] = read_file(file_path)
        # end

        diagnostics = Tzukuri::Diagnostics.new

        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        @entries = diagnostics.entries_for_token_date(params[:token], params[:date])

        @page_title = "#{@auth_token.api_device.name} / #{params[:date]}"
    end

    # display the contents of a file
    def display
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        path = Rails.root.join('diagnostics', params[:token], params[:date], params[:file])

        @file_data = read_file(path)

        @page_title = "#{@auth_token.api_device.name} / #{params[:date]} / #{params[:file]}"
    end

    private

    # read a file and return the blocks of as well as some aggregate data about that file
    def read_file(file_path)
      bytes = IO.binread(file_path)
      io = StringIO.new(bytes)

      data = {
        :blocks => [],
        :num_entries => 0,
        :start_time => '',
        :end_time => ''
      }

      until io.eof?
        begin
          block = Tzukuri::Block.new(io)
          data[:blocks] << block
          data[:num_entries] += block.entries.count
        rescue
        end
      end

      data[:start_time] = data[:blocks].first.entries.first.time
      data[:end_time] = data[:blocks].last.entries.last.time

      return data
    end
  end
end
