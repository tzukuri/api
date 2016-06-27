namespace :tzukuri do

  desc "Check each user's score and confirm that it is correct"
  task :validate_beta_scores => :environment do
    alert_required = false
    file_path = 'log/beta/score_conflict_' + Time.now.strftime('%s') + '.csv'
    out_string = ['id', 'email', 'invitees', 'identities', 'responses', 'score', 'expected_score'].join(',') + "\n"

    BetaUser.all.each do |betauser|
      num_invitees = betauser.invitees.count
      num_accounts = betauser.identities.count
      num_responses = betauser.responses.count

      expected_score = (num_invitees * Tzukuri::INVITEE_POINTS) + (num_accounts * Tzukuri::SOCIAL_POINTS) + (num_responses * Tzukuri::RESPONSE_POINTS)

      if (expected_score != betauser.score)
        alert_required = true
        out_string << [betauser.id, betauser.email, num_invitees, num_accounts, num_responses, betauser.score, expected_score].join(',') + "\n"
      end

    end

    if (alert_required)
      # write csv to file
      File.open(file_path, 'a') {|file| file.write(out_string)}

      # send an email to alert of changes
      BetaMailer.send_score_conflict_alert(file_path).deliver_now

      puts 'wrote conflicts to ' + file_path
    end
  end



end
