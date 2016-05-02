class CreateBetaSignups < ActiveRecord::Migration
  def change
    create_table :beta_signups do |t|

      t.string    :email
      t.string    :country
      t.boolean   :selected
      t.integer   :invited_by_id
      t.string    :invite_code

      t.timestamps
    end
  end
end
