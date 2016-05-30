class CreateBetaQuestions < ActiveRecord::Migration
  def change
    create_table :beta_questions do |t|
      t.string  "content"
      t.integer "point_value"

      t.timestamps null: false
    end
  end
end
