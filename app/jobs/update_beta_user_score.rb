class UpdateBetaUserScore < Que::Job
  @queue = 'beta_scores'

  def run(id)
    user = BetaUser.find(id)
    user.update!(score: user.calculated_score)
  end
end
