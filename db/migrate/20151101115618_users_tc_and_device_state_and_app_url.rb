class UsersTcAndDeviceStateAndAppUrl < ActiveRecord::Migration
    def change
        add_column :users, :confirmed_tc_version, :integer
        add_column :devices, :current_state, :integer, default: 0
        add_column :devices, :current_coords, :string
        add_column :devices, :current_set_by_auth_id, :integer
        add_column :devices, :current_at, :datetime
        add_column :apps, :token_id, :string
        add_column :apps, :private_key, :string
        add_column :apps, :callback_url, :string
    end
end
