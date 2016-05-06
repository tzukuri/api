class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
        t.string :email
        t.string :frame
        t.string :colour
        t.string :size
        t.string :customer_id
        t.string :name
        t.string :address1
        t.string :address2
        t.string :postcode
        t.string :country
        t.string :state
        t.timestamps
    end
  end
end
