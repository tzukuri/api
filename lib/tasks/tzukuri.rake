require 'fileutils'

namespace :tzukuri do

  desc "Check each user's score and confirm that it is correct"
  task :validate_beta_scores => :environment do
    alert_required = false
    force_update = ENV['update']
    out_string = ['id', 'email', 'invitees', 'identities', 'responses', 'score', 'expected_score'].join(',') + "\n"

    BetaUser.all.each do |beta_user|
      expected_score = beta_user.calculated_score

      # if there is a conflict with the score
      if (expected_score != beta_user.score.to_i)
        alert_required = true
        out_string << [beta_user.id, beta_user.email, beta_user.invitees.count, beta_user.identities.count, beta_user.responses.count, beta_user.score.to_i, expected_score].join(',') + "\n"

        # we are forcing an update, so update the attributes
        if (force_update)
          # queue a score update for this user
          UpdateBetaUserScore.enqueue(beta_user.id)
        end

      end

    end

    # if there are any conflicts, write them to a file and alert the team
    if (alert_required)
      FileUtils.mkdir_p('log/beta')
      file_path = 'log/beta/score_conflict_' + Time.now.strftime('%s') + '.csv'
      File.open(file_path, 'a+') {|file| file.write(out_string)}
      BetaMailer.send_score_conflict_alert(file_path, force_update).deliver_later
      puts 'wrote conflicts to ' + file_path
    end
  end

  desc "Print some simple stats"
  task :stats => :environment do
    @inviters = []
    all_users = BetaUser.all
    roots = BetaUser.all.select(&:root?)
    max_depth = dfs_depth(roots, 1)
    response_count = BetaResponse.all.count
    identity_count = BetaIdentity.all.count

    @inviters.sort_by!(&:first).reverse!

    puts "Users: #{all_users.count}"
    puts "Max depth: #{max_depth}"
    puts "Responses: #{response_count} (avg. #{response_count.to_f / all_users.count})"
    puts "Connections: #{identity_count} (avg. #{identity_count.to_f / all_users.count})"
    puts "\nTop inviters:\n#{@inviters[0...15].map {|row| "#{row.last} (#{row.first})" }.join("\n")}"
  end

  def dfs_depth(users, depth)
    depths = [depth]

    users.each do |user|
      invitations = user.invitees.to_a
      @inviters << [invitations.count, user.name]
      depths << dfs_depth(user.invitees.to_a, depth + 1)
    end

    depths.max
  end
end
