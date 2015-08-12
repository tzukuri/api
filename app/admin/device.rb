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

    form do |f|
        f.inputs "Device Details" do
            f.input :mac_address
            f.input :frame
            f.input :size
            f.input :colour
            f.input :frame_manufacture_ts, as: :datepicker
            f.input :board_manufacture_ts, as: :datepicker
            f.input :board_revision
            f.input :frame_revision
            f.input :firmware_version
            f.input :charge_qc_pass_ts, as: :datepicker
            f.input :rf_qc_pass_ts, as: :datepicker
            f.input :shipped, as: :datepicker
        end
        f.actions
    end
end
