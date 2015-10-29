class User < ActiveRecord::Base
    acts_as_token_authenticatable

    devise :database_authenticatable, :recoverable, :rememberable, :trackable,
           :validatable, :lockable, :omniauthable

    has_many :ownerships
    has_many :devices, through: :ownerships

    def current_ownerships
        ownerships.where(revoked: nil)
    end
end
