class AddFieldsToDevices < ActiveRecord::Migration
    def change
        add_column :devices, :charger_revision, :string
        add_column :devices, :serial, :string
        add_column :devices, :pin, :integer
        rename_column :devices, :firmware_version, :firmware_revision
        rename_column :devices, :board_manufacture_ts, :hardware_manufacture_ts
        rename_column :devices, :board_revision, :hardware_revision
    end
end
