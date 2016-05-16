class AddBirthdayToBetaSignup < ActiveRecord::Migration
  def change
    add_column :beta_signups, :birth_date, :date
  end
end
