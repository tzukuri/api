class Api::V0::DeviceBatchesController < Api::ApiController
    # get a list of all batches that are not complete
    def index
      incomplete_batches = DeviceBatch.select{ |batch| !batch.complete?}.map{|batch| {id: batch.id, size: batch.devices.count, ts: batch.updated_at.in_time_zone('Australia/Sydney').strftime("%d/%m/%y %I:%M %p")}}

      incomplete_batches.reverse!

      render json: {
        success: true,
        batches: incomplete_batches
      }
    end

    def show
      batch = DeviceBatch.find(params[:id])
      render json: batch_json(batch)
    end

    private

    def batch_json(batch)
      {
        success: true,
        detail: batch.attributes.merge({
            complete: batch.complete?
        }),
        devices: batch.devices.map {|device| {id: device.id, mac_address: device.mac_address, pin: device.pin, complete: device.complete?}}
      }
    end
end
