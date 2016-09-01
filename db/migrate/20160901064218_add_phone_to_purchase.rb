class AddPhoneToPurchase < ActiveRecord::Migration
  def change
        add_column :purchases, :phone, :string
  end
end
