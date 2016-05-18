class BetaResponse < ActiveRecord::Base
  # make sure that each user has only one answer to each question
  validates :beta_question_id, :uniqueness => {:scope => :beta_user_id}

  belongs_to :question, :class_name => "BetaQuestion", :foreign_key => "id"
  belongs_to :responder, :class_name => "BetaUser", :foreign_key => "id"
end
