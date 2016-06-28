class UpdateBetaUserScore < Que::Job
  @queue = 'beta_scores'

  def run(beta_user_id, new_score)
    beta_user = BetaUser.find(beta_user_id)
    beta_user.update_attribute('score', new_score)
  end
end
