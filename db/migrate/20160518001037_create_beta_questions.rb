class CreateBetaQuestions < ActiveRecord::Migration
  def change
    create_table :beta_questions do |t|
      t.string  "content"
      t.integer "point_value"

      t.timestamps null: false
    end

    # insert questions into the database
    BetaQuestion.create(content: "What is your occupation?", point_value: 1 )
    BetaQuestion.create(content: "What is your yearly income?", point_value: 1)
    BetaQuestion.create(content: "How old are you?", point_value: 1)
    BetaQuestion.create(content: "Which city do you live in?", point_value: 1)
    BetaQuestion.create(content: "Which phone do you have?", point_value: 1)
    BetaQuestion.create(content: "Do you wear optical glasses?", point_value: 1)
    BetaQuestion.create(content: "Where do you purchase your optical glasses?", point_value: 1)
    BetaQuestion.create(content: "Do you wear sunglasses?", point_value: 1)
    BetaQuestion.create(content: "Where do you purchase your sunglasses?", point_value: 1)
    BetaQuestion.create(content: "How often do you lose your glasses?", point_value: 1)
  end
end
