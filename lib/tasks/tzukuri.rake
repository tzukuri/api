namespace :tzukuri do

  desc "Check each user's score and confirm that it is correct"
  task :validate_beta_scores => :environment do
    alert_required = false
    force_update = ENV['update']
    file_path = 'log/beta/score_conflict_' + Time.now.strftime('%s') + '.csv'
    out_string = ['id', 'email', 'invitees', 'identities', 'responses', 'score', 'expected_score'].join(',') + "\n"

    BetaUser.all.each do |betauser|
      num_invitees = betauser.invitees.count
      num_accounts = betauser.identities.count
      num_responses = betauser.responses.count

      expected_score = (num_invitees * Tzukuri::INVITEE_POINTS) + (num_accounts * Tzukuri::SOCIAL_POINTS) + (num_responses * Tzukuri::RESPONSE_POINTS)

      # if there is a conflict with the score
      if (expected_score != betauser.score)
        alert_required = true
        out_string << [betauser.id, betauser.email, num_invitees, num_accounts, num_responses, betauser.score, expected_score].join(',') + "\n"

        # we are forcing an update, so update the attributes
        if (force_update)
          betauser.update_attribute('score', expected_score)
          puts 'forced update score for ' + betauser.email
        end
      end

    end

    # if there are any conflicts, write them to a file and alert the team
    if (alert_required)
      File.open(file_path, 'a') {|file| file.write(out_string)}

      BetaMailer.send_score_conflict_alert(file_path, force_update).deliver_later

      puts 'wrote conflicts to ' + file_path
    else
      puts 'no conflicts found'
    end
  end



end
