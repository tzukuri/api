class AuthTokensHaveDiagnosticsSyncToken < ActiveRecord::Migration
    def change
        add_column :auth_tokens, :diagnostics_sync_token, :string
    end
end
