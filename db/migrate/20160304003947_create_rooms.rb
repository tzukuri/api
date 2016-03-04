class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :quietzone, index: true, foreign_key: true

      t.timestamps null: false
    end

    # so that we can look up rooms by their quiet zones efficiently
    add_index :rooms, [:quietzone_id, :created_at]
  end
end
