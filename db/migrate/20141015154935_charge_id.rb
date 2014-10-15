class ChargeId < ActiveRecord::Migration
  def change
    add_column :purchases, :charge_id, :string
  end
end
