class TrackAppVersion < ActiveRecord::Migration
    def change
        remove_column :users, :authentication_token
        add_column :auth_tokens, :email, :string
        add_column :auth_tokens, :app_version, :string
    end
end
