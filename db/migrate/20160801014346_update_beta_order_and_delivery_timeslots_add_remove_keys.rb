class UpdateBetaOrderAndDeliveryTimeslotsAddRemoveKeys < ActiveRecord::Migration
  def change

    remove_column :beta_delivery_timeslots, :beta_order_id
    remove_column :beta_delivery_timeslots, :timeslot
    add_column :beta_delivery_timeslots, :time, :datetime

    add_column :beta_orders, :beta_delivery_timeslot_id, :integer

  end
end
