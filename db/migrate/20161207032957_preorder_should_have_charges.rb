class PreorderShouldHaveCharges < ActiveRecord::Migration
  def change
    remove_column :preorders, :charge_id
    add_column :preorders, :charge_id, :integer
    remove_column :preorders, :customer_id
  end
end
