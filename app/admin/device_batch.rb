ActiveAdmin.register DeviceBatch do
  menu parent: 'API'
  permit_params :batch_size
  actions :all, :except => [:edit]

  index do
      id_column

      column("# Devices") { |device_batch| device_batch.devices.count }
      column :complete? do |device_batch|
        device_batch.complete? ? status_tag("YES") : status_tag("NO")
      end
      column :created_at
      column :updated_at

      actions
  end

  show do
    panel "Batch Details" do
      table_for device_batch do
        column :id
        column("# Devices") { |device_batch| device_batch.devices.count }
        column :complete? do |device_batch|
          device_batch.complete? ? status_tag("YES") : status_tag("NO")
        end
        column :created_at
        column :updated_at
      end
    end

    panel "Batch Devices" do
      table_for device_batch.devices do
        column :id
        column :mac_address
        column :pin

        column :design
        column :size
        column :colour
        column :optical
        column :hardware_revision
        column :serial
        column :complete? do |device|
          device.complete? ? status_tag("YES") : status_tag("NO")
        end
      end
    end
  end

  form do |f|
      f.inputs "Request Batch" do
        f.input :batch_size
      end
      f.actions
  end

  controller do
    PIN_LENGTH = 6
    PIN_PREFIX = 1
    MAC_INCREMENT = 2
    HARDWARE_REV = "Rev3E"

    def create
      batch_size = create_params[:batch_size].to_i

      # prevent users from creating a batch with less than 1 devices
      if batch_size < 1
        flash[:notice] = I18n.t('empty_batch')
        redirect_to :back
        return
      end

      # create the new batch these devices are going into
      batch = DeviceBatch.create

      # sets to track new and existing pins
      existing_pins = Set.new(Device.all.map(&:pin))
      new_pins = Set.new

      for i in 1..batch_size do
        pin = nil
        mac = generate_mac
        pin = generate_pin while pin.nil? || existing_pins.include?(pin) || new_pins.include?(pin)
        serial = mac[0..5] + "FFFE" + mac[6..11]

        new_pins << pin

        device = Device.create(mac_address: mac, pin: pin, device_batch_id: batch.id, serial: serial, hardware_revision: HARDWARE_REV)
      end

      redirect_to admin_device_batch_path(batch)
    end

    private

    def create_params
      params.require(:device_batch).permit(:batch_size)
    end

    def generate_mac
      # devices with the Tzukuri prefix, find the max by the integer value of the address
      last_mac = Device.where("mac_address ~* ?", '60D262.').map(&:mac_address).max_by { |mac| mac.to_i(16) }
      # increment the address, convert to a base 16 string and convert to uppercase
      (last_mac.to_i(16) + MAC_INCREMENT).to_s(16).upcase
    end

    def generate_pin
      digits = [PIN_PREFIX]

      (PIN_LENGTH - 1).times do
        digits << (0..9).to_a.sample
      end

      digits.map(&:to_s).join
    end

  end

end
