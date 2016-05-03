class AddPointsToBetaSignups < ActiveRecord::Migration
  def change
    add_column :beta_signups, :score, :integer, :default => 0
    add_index :beta_signups, :invite_code
  end
end
