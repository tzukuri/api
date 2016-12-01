class DeviceBatch < ActiveRecord::Base
  has_many :devices

  attr_accessor :batch_size

  # returns true if all the devices in this batch are complete
  def complete?
    complete = true

    devices.each do |device|
      if !device.complete?
        complete = false
        break
      end
    end

    return complete
  end

end
