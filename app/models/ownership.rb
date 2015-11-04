class Ownership < ActiveRecord::Base
    belongs_to :device
    belongs_to :user

    scope :active, -> { where revoked: nil }

    validates :device_id, presence: true
    validates :user_id, presence: true

    def owner?(user)
        user_id == user.id
    end

    def active?
        revoked.nil?
    end

    def revoke!(reason:)
        self.revoked = Time.now.utc
        self.reason  = reason
        save!
    end
end
