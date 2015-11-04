class AuthTokensStoreApns < ActiveRecord::Migration
    def change
        add_column :auth_tokens, :apns_token, :string
        add_column :auth_tokens, :app_version, :string
    end
end
