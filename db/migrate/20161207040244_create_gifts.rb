class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :purchased_by
      t.string :code
      t.timestamp :expires_at
      t.integer :charge_id

      t.timestamps null: false
    end
  end
end
