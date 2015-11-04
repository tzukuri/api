class AuthTokensAreRevoked < ActiveRecord::Migration
    def change
        remove_column :auth_tokens, :invalid
        add_column :auth_tokens, :revoked, :datetime
        add_column :auth_tokens, :reason, :string
    end
end
