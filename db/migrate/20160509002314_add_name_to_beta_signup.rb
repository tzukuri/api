class AddNameToBetaSignup < ActiveRecord::Migration
  def change
        add_column :beta_signups, :name, :string
        remove_column :beta_signups, :selected
        add_column :beta_signups, :selected, :boolean, :default => false
  end
end
