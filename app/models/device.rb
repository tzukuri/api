class Device < ActiveRecord::Base
    has_many :ownerships

    def current_owner
        ownerships.where(revoked: nil).first
    end

    def name
        "#{id} (#{mac_address}, #{frame}, #{size}, #{colour})"
    end
end
