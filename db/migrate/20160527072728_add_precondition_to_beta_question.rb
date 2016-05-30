class AddPreconditionToBetaQuestion < ActiveRecord::Migration
  def change
    add_column :beta_questions, :precondition_id, :integer
  end
end
