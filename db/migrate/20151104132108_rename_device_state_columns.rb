class RenameDeviceStateColumns < ActiveRecord::Migration
    def change
        rename_column :devices, :current_state, :state
        rename_column :devices, :current_set_by_auth_id, :state_set_by_auth_id
        rename_column :devices, :current_at, :state_set_at
        
        remove_column :devices, :current_coords
        add_column    :devices, :latitude, :float
        add_column    :devices, :longitude, :float
        add_column    :devices, :coords_set_by_auth_id, :integer
        add_column    :devices, :coords_set_at, :datetime
    end
end
