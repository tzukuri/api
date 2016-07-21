class DiagnosticsController < ApplicationController

  def index
    f_name = 'diagnostics/yzVBHmzATP8BhJJmtMoj/2016-07-21/70A1AE27-2579-4A7B-843E-909A10953F78'
    bytes = IO.binread(f_name)
    io = StringIO.new(bytes)
    @block = Block.new(io)
  end

  def show

  end

end
