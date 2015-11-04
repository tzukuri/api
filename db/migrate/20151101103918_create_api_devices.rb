class CreateApiDevices < ActiveRecord::Migration
    def change
        create_table :api_devices do |t|
            t.string :token_id
            t.string :launch_language
            t.string :preferred_language
            t.string :locale
            t.string :name
            t.string :os
            t.string :type
            t.timestamps null: false
        end
    end
end
