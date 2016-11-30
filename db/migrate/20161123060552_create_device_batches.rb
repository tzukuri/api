class CreateDeviceBatches < ActiveRecord::Migration
  def change
    create_table :device_batches do |t|
      t.boolean :complete, default: false

      t.timestamps null: false
    end
  end
end
