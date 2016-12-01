ActiveAdmin.register Device do
    menu parent: 'API'

    permit_params :mac_address, :design, :size, :colour, :frame_manufacture_ts,
                  :board_manufacture_ts, :board_revision, :frame_revision,
                  :firmware_version, :charge_qc_pass_ts, :rf_qc_pass_ts, :shipped, :optical

    index do
        selectable_column
        id_column
        column :device_batch_id do |device|
          if !device.device_batch.nil?
            link_to device.device_batch_id, admin_device_batch_path(device.device_batch) unless device.device_batch_id.blank?
          else
            "N/A"
          end
        end
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
end
