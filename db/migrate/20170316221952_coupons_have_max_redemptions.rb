class CouponsHaveMaxRedemptions < ActiveRecord::Migration
  def change
    add_column :coupons, :max_redemptions, :integer
  end
end
