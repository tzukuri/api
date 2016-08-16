ActiveAdmin.register Device do
    permit_params :mac_address, :design, :size, :colour, :frame_manufacture_ts,
                  :board_manufacture_ts, :board_revision, :frame_revision,
                  :firmware_version, :charge_qc_pass_ts, :rf_qc_pass_ts, :shipped, :optical

    index do
        selectable_column
        id_column
        column :mac_address
        column :design
        column :size
        column :colour
        column :hardware_revision
        column :serial
        column :pin
        column :optical
        actions
    end

    # filter :mac_address
    # filter :frame
    # filter :shipped
end
