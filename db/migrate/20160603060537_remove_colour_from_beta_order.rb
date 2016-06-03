class RemoveColourFromBetaOrder < ActiveRecord::Migration
  def change
    remove_column :beta_orders, :colour
  end
end
