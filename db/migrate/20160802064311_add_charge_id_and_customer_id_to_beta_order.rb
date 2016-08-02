class AddChargeIdAndCustomerIdToBetaOrder < ActiveRecord::Migration
  def change
        add_column :beta_orders, :charge_id, :string
        add_column :beta_orders, :customer_id, :string
  end
end
