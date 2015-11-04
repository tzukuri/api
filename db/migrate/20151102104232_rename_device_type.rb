class RenameDeviceType < ActiveRecord::Migration
    def change
        rename_column :api_devices, :type, :device_type
    end
end
