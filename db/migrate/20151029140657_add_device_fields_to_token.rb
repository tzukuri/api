class AddDeviceFieldsToToken < ActiveRecord::Migration
    def change
        add_column :auth_tokens, :device_type, :string
        add_column :auth_tokens, :device_name, :string
    end
end
