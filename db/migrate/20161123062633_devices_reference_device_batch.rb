class DevicesReferenceDeviceBatch < ActiveRecord::Migration
  def change
    add_reference :devices, :device_batch, index: true
  end
end
