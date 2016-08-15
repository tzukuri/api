ActiveAdmin.register Device do
    permit_params :mac_address, :frame, :size, :colour, :frame_manufacture_ts,
                  :board_manufacture_ts, :board_revision, :frame_revision,
                  :firmware_version, :charge_qc_pass_ts, :rf_qc_pass_ts, :shipped

    index do
        selectable_column
        id_column
        column :mac_address
        column :frame
        column :size
        column :colour
        actions
    end

    filter :mac_address
    filter :frame
    filter :shipped
end
