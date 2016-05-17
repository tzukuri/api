class CreateBetaUsers < ActiveRecord::Migration
  def change
    create_table :beta_users do |t|

      t.string  "email",        default: "", null: false
      t.string  "name"
      t.string  "invite_token"
      t.float   "score",        default: 0
      t.boolean "selected"
      t.string  "user_agent"
      t.string  "ip_address"

      t.timestamps null: false
    end

    add_index :beta_users, :email, unique: true
    add_index :beta_users, :invite_token

  end
end
