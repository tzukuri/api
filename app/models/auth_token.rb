class AuthToken < ActiveRecord::Base
    belongs_to :api_device
    belongs_to :user
    belongs_to :app
    has_many :log_entries, dependent: :destroy

    scope :active, -> { where revoked: nil }

    validates :user_id, presence: true
    validates :app_id, presence: true
    validates :token, presence: true
    validates :email, presence: true

    def matches?(other_token, other_app_id)
        revoked.nil? &&
            Devise.secure_compare(token, other_token) &&
            app_id == other_app_id.to_i
    end

    def revoke!(reason:)
        self.revoked = Time.now.utc
        self.reason  = reason
        save!
    end

    def self.active_token_for(user:, app:, api_device:)
        AuthToken.where(
            api_device_id: api_device.id,
            user_id: user.id,
            app_id: app.id,
            revoked: nil
        ).first
    end

    def self.create_for!(user:, app:, api_device:)
        AuthToken.create!(
            api_device_id: api_device.id,
            user_id: user.id,
            app_id: app.id,
            email: user.email,
            token: Devise.friendly_token,
            diagnostics_sync_token: Devise.friendly_token
        )
    end
end
