class AddCityAndBirthdateToBetauser < ActiveRecord::Migration
  def change
    add_column :beta_users, :birth_date, :date
    add_column :beta_users, :country, :string
    add_column :beta_users, :city, :string
  end
end
