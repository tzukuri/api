class DropBetaSignupModel < ActiveRecord::Migration
  def change
    drop_table :beta_signups
  end
end
