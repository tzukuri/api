class CreateOwnerships < ActiveRecord::Migration
    def change
        create_table :ownerships do |t|
            t.integer   :user_id
            t.integer   :device_id
            t.datetime  :revoked
            t.string    :reason
            t.timestamps null: false
        end
    end
end
