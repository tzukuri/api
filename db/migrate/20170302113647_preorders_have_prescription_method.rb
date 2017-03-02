class PreordersHavePrescriptionMethod < ActiveRecord::Migration
  def change
    add_column :preorders, :prescription_method, :string
  end
end
