class CreateBetaDeliveryTimeslots < ActiveRecord::Migration
  def change
    create_table :beta_delivery_timeslots do |t|
      t.references :beta_order, index: true, foreign_key: true

      t.datetime :timeslot
      t.timestamps null: false
    end
  end
end
