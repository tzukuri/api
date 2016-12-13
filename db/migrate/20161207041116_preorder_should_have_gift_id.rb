class PreorderShouldHaveGiftId < ActiveRecord::Migration
  def change
    add_column :preorders, :gift_id, :integer
  end
end
