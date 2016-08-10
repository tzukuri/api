class AddDeliveryMethodToBetaOrder < ActiveRecord::Migration
  def change
    add_column :beta_orders, :delivery_method, :integer
    add_column :beta_orders, :fulfilled, :boolean, default: false
  end
end
