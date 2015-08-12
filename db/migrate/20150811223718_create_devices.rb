class CreateDevices < ActiveRecord::Migration
    def change
        create_table :devices do |t|
            t.string    :mac_address
            t.string    :frame
            t.string    :size
            t.string    :colour
            t.datetime  :frame_manufacture_ts
            t.datetime  :board_manufacture_ts
            t.string    :board_revision
            t.string    :frame_revision
            t.string    :firmware_version
            t.datetime  :charge_qc_pass_ts
            t.datetime  :rf_qc_pass_ts
            t.datetime  :shipped
            t.timestamps null: false
        end

        add_index :devices, :mac_address, unique: true
    end
end
