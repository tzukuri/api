class CreateOrderEvents < ActiveRecord::Migration
  def change
    create_table :order_events do |t|
      t.string :name
      t.integer :preorder_id

      t.timestamps null: false
    end
  end
end
