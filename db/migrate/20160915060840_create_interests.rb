class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :name
      t.string :email
      t.string :city
      t.string :country
      t.timestamps null: false
    end
  end
end
