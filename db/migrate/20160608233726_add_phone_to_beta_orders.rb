class AddPhoneToBetaOrders < ActiveRecord::Migration
  def change
    add_column :beta_orders, :phone, :string
  end
end
