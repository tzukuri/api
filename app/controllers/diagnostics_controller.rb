  class DiagnosticsController < ApplicationController

  def index
    f_name = "diagnostics/#{params[:diag_token]}/#{params[:date]}/#{params[:file_name]}"

    begin
      bytes = IO.binread(f_name)
      io = StringIO.new(bytes)
      @block = Block.new(io)
    rescue
      # todo: handle a file name that doesn't exist
    end
  end

end
