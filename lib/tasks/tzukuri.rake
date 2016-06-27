namespace :tzukuri do

  desc "Check each user's score and confirm that it is correct"
  task :check_beta_score => :environment do
    BetaUser.all.each do |betauser|
      num_invitees = betauser.invitees.count
      num_accounts = betauser.identities.count
      num_responses = betauser.responses.count

      expected_score = (num_invitees * Tzukuri::INVITEE_POINTS) + (num_accounts * Tzukuri::SOCIAL_POINTS) + (num_responses * Tzukuri::RESPONSE_POINTS)

      if (expected_score != betauser.score)
        # set the user's score to the expected score if they do not match
        betauser.update_attribute('score', expected_score)
      end
    end
  end



end
