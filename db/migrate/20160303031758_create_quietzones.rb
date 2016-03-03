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

    # make sure that we can efficiently look up users by their index
    add_index :quietzones, [:user_id, :created_at]
  end
end
