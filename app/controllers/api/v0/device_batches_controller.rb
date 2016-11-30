class Api::V0::DeviceBatchesController < Api::ApiController
    PIN_LENGTH = 6
    PIN_PREFIX = 1
    MAC_INCREMENT = 2

    # get a list of all batches that are not complete
    def index
      incomplete_batches = DeviceBatch.select{ |batch| !batch.complete?}.map{|batch| {id: batch.id, size: batch.devices.count, ts: batch.updated_at.strftime("%d/%m/%y %I:%M %p")}}

      incomplete_batches.reverse!

      render json: {
        success: true,
        batches: incomplete_batches
      }

    end

    # get a list of devices for a given batch
    def show
      batch = DeviceBatch.find(params[:id])
      render json: batch_json(batch)
    end

    # generate a batch
    def create
      batch_size = params[:batch_size].to_i
      render_error(:empty_batch, status: 422) unless batch_size > 0

      # create the new batch these devices are going into
      batch = DeviceBatch.create

      # sets to track new and existing pins
      existing_pins = Set.new(Device.all.map(&:pin))
      new_pins = Set.new

      for i in 1..batch_size do
        pin = nil
        mac = generate_mac
        pin = generate_pin while pin.nil? || existing_pins.include?(pin) || new_pins.include?(pin)
        serial = mac[0..6] + "FFFE" + mac[6..11]

        new_pins << pin

        device = Device.create(mac_address: mac, pin: pin, device_batch_id: batch.id, serial: serial, hardware_revision: "Beta 😎")
      end
      
      render json: batch_json(batch)
    end

    private

    def generate_mac()
      last_mac = Device.last.mac_address
      (last_mac.to_i(16) + MAC_INCREMENT).to_s(16).upcase
    end

    def generate_pin()
      digits = [PIN_PREFIX]

      (PIN_LENGTH - 1).times do
        digits << (0..9).to_a.sample
      end

      digits.map(&:to_s).join
    end

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
