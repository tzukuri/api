class AddCityToBetaUser < ActiveRecord::Migration
  def change
        add_column :beta_users, :city, :string
  end
end
