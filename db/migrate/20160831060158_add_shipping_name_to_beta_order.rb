class AddShippingNameToBetaOrder < ActiveRecord::Migration
  def change
    add_column :beta_orders, :shipping_name, :string
  end
end
