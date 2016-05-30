class AddIndexToBetaUserForRanking < ActiveRecord::Migration
  def change
    add_index :beta_users, :score, using: 'btree'
  end
end
