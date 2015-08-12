class Device < ActiveRecord::Base
    has_many :ownership
    # current_owner

    def name
        "#{id} (#{mac_address}, #{frame}, #{size}, #{colour})"
    end
end
