class Device < ActiveRecord::Base
    has_many :ownerships, -> { Ownership.active }
    belongs_to :device_batch

    validates_uniqueness_of :pin, :mac_address

    enum state: [:unknown, :connected, :disconnected]

    def current_owner
        ownerships.first.try(:user)
    end

    def owner?(user)
        return false if ownerships.count != 1
        current_owner.id == user.id
    end

    def linked?
        ownerships.exists?
    end

    def pin_matches?(other_pin)
        pin == other_pin.to_i
    end

    def link_to!(user)
        Ownership.create!(
            device_id: id,
            user_id: user.id
        )
    end

    def unlink_from!(user:, reason:)
        ownership = ownerships.where(user_id: user.id).first!
        ownership.revoke!(reason: reason)
    end

    def coords_set_time
      epoch_time(coords_set_at)
    end

    def state_set_time
      epoch_time(state_set_at)
    end

    def name
        "#{id} (#{serial}, #{design}, #{colour})"
    end

    # returns true if the device has a id, mac, pin, serial, design, colour, size, optical? and hardware_revision
    def complete?
      !id.blank? && !mac_address.blank? && !pin.blank? && !design.blank? && !colour.blank? && !hardware_revision.blank?
    end

    private

    def epoch_time(ts)
      return if ts.nil?

      epoch = Time.new(2001,1,1,0,0,0,0).to_i # NSDate epoch
      Time.at(epoch + ts).in_time_zone('Australia/Sydney')
    end
end
