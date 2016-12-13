class GiftsHaveEngravings < ActiveRecord::Migration
  def change
    add_column :gifts, :engraving, :string
  end
end
