json.success true
json.devices @devices do |device|
    json.serial device.serial
    json.design device.design
    json.colour device.colour
end
