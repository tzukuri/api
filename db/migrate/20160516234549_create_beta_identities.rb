class CreateBetaIdentities < ActiveRecord::Migration
  def change
    create_table :beta_identities do |t|
      t.references :beta_user, index: true, foreign_key: true
      t.string :provider
      t.string :access_token
      t.string :private_token
      t.string :uid

      t.timestamps null: false
    end
  end
end
