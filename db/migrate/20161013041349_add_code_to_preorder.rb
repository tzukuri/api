class AddCodeToPreorder < ActiveRecord::Migration
  def change
    add_column :preorders, :code, :string
  end
end
