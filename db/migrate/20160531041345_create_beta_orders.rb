class CreateBetaOrders < ActiveRecord::Migration
  def change
    create_table :beta_orders do |t|
      t.references :beta_user, index: true, foreign_key: true
      t.string :address1
      t.string :address2
      t.string :state
      t.string :postcode
      t.string :country
      t.string :frame
      t.string :colour
      t.string :size

      t.timestamps null: false
    end
  end
end
