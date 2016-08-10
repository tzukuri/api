class RemoveChargeAndCustomerIdFromBetaOrder < ActiveRecord::Migration
  def change
        remove_column :beta_orders, :charge_id
        remove_column :beta_orders, :customer_id
  end
end
