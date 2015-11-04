class LogIndexes < ActiveRecord::Migration
    def change
        add_index :log_entries, [:auth_token_id, :created_at, :type], order: {created_at: :desc}
    end
end
