class CreateLogEntries < ActiveRecord::Migration
    def change
        create_table :log_entries do |t|
            t.integer   :auth_token_id
            t.datetime  :created_at
            t.string    :type
            t.string    :data
        end

        add_column :auth_tokens, :invalid, :boolean
    end
end
