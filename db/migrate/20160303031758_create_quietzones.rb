class CreateQuietzones < ActiveRecord::Migration
  def change
    create_table :quietzones do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.integer :radius
      t.time :starttime
      t.time :endtime
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

  end
end
