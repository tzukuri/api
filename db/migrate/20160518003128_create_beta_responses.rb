class CreateBetaResponses < ActiveRecord::Migration
  def change
    create_table :beta_responses do |t|
      t.integer :beta_user_id
      t.integer :beta_question_id
      t.string  :response

      t.timestamps null: false
    end
  end
end
