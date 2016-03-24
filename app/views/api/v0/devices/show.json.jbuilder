json.success true
json.device do
    # device details
    json.hardware_revision @device.hardware_revision
    json.serial @device.serial
    json.design @device.design
    json.colour @device.colour
    json.optical @device.optical
    
    # device parameters
    json.params do
        json.notifications do
            json.low_battery_threshold          412
            json.disconnect_grace_period        7
            json.disconnect_throttling_period   120
        end

        json.connection do
            json.temporary_disconnect_period    30
        end

        # distance calculation parameters
        json.distance do
            json.measured_1m    -63
            json.db_std_dev     1.0
            json.path_loss_exp  4.5

            json.rssi_kalman do
                json.Q  0.5
                json.R  7.13
                json.p  0.0
                json.k  0.5
            end

            json.channels (0...37) do
                json.chebyshev_k 2
                json.kalman do
                    json.Q  0.5
                    json.R  7.13
                    json.p  0.0
                    json.k  0.5
                end
            end
        end
    end
end
