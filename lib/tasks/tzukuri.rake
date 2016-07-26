require 'fileutils'

namespace :tzukuri do

  desc "Prepare a report for beta user selection"
  task :beta_report => :environment do
    # build up a out_string and write to a .csv file for loading into excel
    out_string = ['id', 'name', 'email', 'age', 'score', 'twitter_handle', 'num_twitter_followers', 'instagram_handle', 'num_instagram_followers', 'num_responses', 'num_invitees', 'total_connected', 'city'].join(',') + "\n"

    # for all users not from tzukuri
    BetaUser.where.not("email LIKE ?", "%@tzukuri.com").order('created_at').all.each do |beta_user|
      puts "processing " + beta_user.id.to_s

      # use -1 to indicate that no account is associated with this account
      twitter_followers = -1
      twitter_handle = ""
      instagram_followers = -1
      instagram_handle = ""

      if beta_user.twitter?
        begin
          t_user = beta_user.twitter_client.user
          twitter_followers = t_user.followers_count
          twitter_handle = t_user.screen_name
        rescue => e
          puts "error retrieving twitter followers"
        end
      end

      if beta_user.instagram?
        begin
          i_user = beta_user.instagram_client.user
          instagram_followers = i_user.counts.followed_by
          instagram_handle = i_user.username
        rescue => e
          puts "error retrieving instagram followers"
        end
      end

      total_connected = total_connected(beta_user, 0)

      out_string << [beta_user.id, beta_user.name, beta_user.email, age(beta_user.birth_date),beta_user.score, twitter_handle, twitter_followers, instagram_handle, instagram_followers, beta_user.responses.count, beta_user.invitees.count, total_connected, beta_user.city.gsub(',', ' -')].join(',') + "\n"
    end

    FileUtils.mkdir_p('log/beta/reports')
    file_path = 'log/beta/reports/report_' + Time.now.strftime('%s') + '.csv'
    File.open(file_path, 'a+') {|file| file.write(out_string)}
    puts 'wrote report to ' + file_path
  end

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

  def age(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # returns the total number of invitees as a result of this one
  def total_connected(user, total)
    # if we've reached the bottom this user has no more invitees
    return 0 if user.invitees.nil?
    total += user.invitees.count

    user.invitees.each do |user|
      total = total_connected(user, total)
    end

    return total
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
