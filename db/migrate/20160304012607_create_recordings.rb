class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.references :device, index: true, foreign_key: true
      t.string :recording_date
      t.string :date
      t.references :room, index: true, foreign_key: true

      t.timestamps null: false
    end

  end
end
