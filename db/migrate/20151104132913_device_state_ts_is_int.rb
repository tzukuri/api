class DeviceStateTsIsInt < ActiveRecord::Migration
    def change
        rename_column :devices, :coords_set_by_auth_id, :coords_set_by_auth_token_id
        rename_column :devices, :state_set_by_auth_id, :state_set_by_auth_token_id
        remove_column :devices, :coords_set_at
        remove_column :devices, :state_set_at
        add_column    :devices, :coords_set_at, :integer
        add_column    :devices, :state_set_at, :integer
    end
end
