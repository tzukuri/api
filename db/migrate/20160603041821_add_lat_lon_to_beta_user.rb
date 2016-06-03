class AddLatLonToBetaUser < ActiveRecord::Migration
  def change
        add_column :beta_users, :latitude, :float
        add_column :beta_users, :longitude, :float

        remove_column :beta_users, :country
        remove_column :beta_users, :city
  end
end
