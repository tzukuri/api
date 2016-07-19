class Device < ActiveRecord::Base
    has_many :ownerships, -> { Ownership.active }
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

    def name
        "#{id} (#{serial}, #{design}, #{colour})"
    end
end
