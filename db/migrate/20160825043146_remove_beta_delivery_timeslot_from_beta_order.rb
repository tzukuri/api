class RemoveBetaDeliveryTimeslotFromBetaOrder < ActiveRecord::Migration
  def change
    remove_column :beta_orders, :beta_delivery_timeslot_id
    add_column :beta_orders, :delivery_time, :string
  end
end
