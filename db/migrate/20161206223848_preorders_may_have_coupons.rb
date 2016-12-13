class PreordersMayHaveCoupons < ActiveRecord::Migration
  def change
    remove_column :preorders, :code
    add_column :preorders, :coupon_id, :integer
  end
end
