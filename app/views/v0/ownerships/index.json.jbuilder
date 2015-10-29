json.ownerships @ownerships do |ownership|
    json.id ownership.id
    json.mac_address ownership.device.mac_address
    json.frame ownership.device.frame
    json.colour ownership.device.colour
    json.size ownership.device.size
end
