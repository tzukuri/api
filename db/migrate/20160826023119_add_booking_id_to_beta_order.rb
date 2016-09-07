class AddBookingIdToBetaOrder < ActiveRecord::Migration
  def change
    add_column :beta_orders, :booking_id, :string
  end
end
