class User < ActiveRecord::Base
    devise :database_authenticatable, :recoverable, :rememberable, :trackable,
           :validatable, :lockable, :omniauthable

    has_many :ownerships
    has_many :devices, through: :ownerships

    # current_ownerships
end
