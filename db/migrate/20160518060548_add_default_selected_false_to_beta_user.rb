class AddDefaultSelectedFalseToBetaUser < ActiveRecord::Migration
  def change
    change_column :beta_users, :selected, :boolean, :default => false
  end
end
