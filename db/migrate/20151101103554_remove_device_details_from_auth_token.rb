class RemoveDeviceDetailsFromAuthToken < ActiveRecord::Migration
    def change
        remove_column :auth_tokens, :device_type, :string
        remove_column :auth_tokens, :device_name, :string
        remove_column :auth_tokens, :app_version, :string
        add_column :auth_tokens, :api_device_id, :integer
    end
end
