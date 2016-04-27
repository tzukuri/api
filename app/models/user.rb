class User < ActiveRecord::Base
    devise :database_authenticatable, :recoverable, :rememberable,
           :trackable, :validatable, :lockable

    has_many :ownerships
    has_many :auth_tokens
    has_many :quietzones
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

    # override lockable.lock_access
    # def lock_access!(opts = {})
    #     super(opts)
    #     # destroy all auth tokens
    #     self.auth_tokens.destroy_all
    # end

    after_update do |user|
        # if password was changed, destroy all auth tokens
        if user.changes["encrypted_password"]
            user.auth_tokens.destroy_all
        end

        # if email was changed, update all associated tokens with the new email
        if user.changes["email"]
            user.auth_tokens.each do |token|
                token.update!(:email, user.email)
            end
        end
    end
end
