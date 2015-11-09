class User < ActiveRecord::Base
    devise :database_authenticatable, :recoverable, :rememberable,
           :trackable, :validatable, :lockable

    has_many :ownerships
    has_many :auth_tokens
    has_many :active_ownerships,
                -> { Ownership.active },
                class_name: 'Ownership'
    has_many :active_auth_tokens,
                -> { AuthToken.active },
                class_name: 'AuthToken'
    has_many :devices, through: :active_ownerships
    has_many :log_entries, through: :auth_tokens

    validates :name, presence: true, length: { minimum: 2 }
    validates :email, uniqueness: true

    after_update do |record|
        record.auth_tokens.each do |token|
            # TODO: track when this fails and continue on other tokens
            token.update!(:email, record.email)
        end
    end
end
