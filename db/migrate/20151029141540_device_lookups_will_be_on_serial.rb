class DeviceLookupsWillBeOnSerial < ActiveRecord::Migration
    def change
        remove_index :devices, column: :mac_address
        add_index :devices, :serial, unique: true
    end
end
