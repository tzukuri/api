class Ownership < ActiveRecord::Base
    belongs_to :device
    belongs_to :user

    scope :current, -> { where(revoked: nil) }
end
