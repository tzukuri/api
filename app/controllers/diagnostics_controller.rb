require 'rubygems'
require 'lz4-ruby'
require 'DiagnosticsItem'

class DiagnosticsController < ApplicationController

  def index
    # open the file and split into blocks
    f = File.open("diagnostics/KyGgtBnxN25QaPsPgtxS/2016-07-01/0636253D-9424-494D-9C69-6C5EB42A43BE", "rb").read
    blocks = f.split("TZUD")
    diagnostic_items = []

    # look at file byte by byte and reconstruct

    blocks.each do |block|
      # todo: decompress the block
      # d = LZ4::decompress(block) if block.bytesize > 0

      current_item = DiagnosticsItem.new()

      puts block.split(//)

      # block.each_byte do |byte|

      #   # if we haven't finished building the timestamp, add another byte
      #   if !current_item.timestamp_complete
      #     # add the current byte to the timestamp
      #     current_item.add_timestamp_byte(byte)

      #     # todo: check if we've finished with the timestamp
      #     next

      #   elsif !current_item.diagnostic_complete
      #     # set this byte as the diagnostic (will always be one byte)
      #     current_item.add_diagnostic_byte(byte)
      #     current_item.diagnostic_complete = true
      #     next
      #   end

      #   # if we have added a diagnostic and it still expects a value
      #   if current_item.diagnostic_complete && current_item.expects_value
      #     # add this byte to the value array
      #     current_item.add_value_byte(byte)

      #     # todo: check whether we're finished adding a value
      #     next
      #   else
      #     # store the current item in the items array and move on to the next value
      #     diagnostic_items.append(current_image)
      #     current_item = DiagnosticsItem.new()
      #     next
      #   end

      # end

    end

    return diagnostic_items
  end

  def show

  end

end
