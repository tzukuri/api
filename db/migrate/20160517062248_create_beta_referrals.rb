class CreateBetaReferrals < ActiveRecord::Migration
  def change
    create_table :beta_referrals do |t|
      t.integer :inviter_id
      t.integer :invitee_id

      t.timestamps null: false
    end
  end
end
