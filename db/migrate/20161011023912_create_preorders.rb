class CreatePreorders < ActiveRecord::Migration
  def change
    create_table :preorders do |t|
        t.string :name
        t.string :email
        t.string :phone
        t.text   :address_lines, array: true, default: []
        t.string :country
        t.string :state
        t.string :postal_code
        t.string :utility
        t.string :frame
        t.string :size
        t.string :lens
        t.string :customer_id
        t.string :charge_id

        t.timestamps
    end
  end
end
