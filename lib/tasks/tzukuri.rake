require 'fileutils'

namespace :tzukuri do

  namespace :diag do
    desc "How long does the battery last on a user's glasses?"
    task :battery_readings => :environment do
      sync_token = ENV['sync_token']
      abort("exiting, requires token -- sync_token=[sync_token]") if sync_token.blank?

      out_str = ""

      Tzukuri::Diagnostics.analyse(
        sync_tokens: [sync_token]
      ) { |entry|
        out_string << "#{entry.time}, #{entry.value.to_i}\n" if entry.type == "bleReadBattery"
      }

      write_report(out_str, 'battery_readings', "report_#{Time.now.strftime('%s')}_#{sync_token}.csv")
    end

    desc "How many times per day do user's open the app?"
    task :app_opens => :environment do
      sync_tokens = ENV['sync_tokens']
      sync_tokens = sync_tokens.blank? ? [] : sync_tokens.split(',')

      opens = {}
      out_str = ""

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens
      ) { |entry, index, sync_token|
          date = entry.time.to_date
          opens[date] = (opens[date] || 0) + 1 if entry.type == "appDidBecomeActive"
      }

      # sort the hash in order of the dates
      opens = opens.sort_by {|k,v| k}.to_h

      # for every date between the start and the end
      (opens.keys.first..opens.keys.last).each do |date|
        out_str << "#{date}, #{opens[date] || 0}\n"
      end

      write_report(out_str, 'app_opens', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How often do users interact with notifications?"
    task :notifications_tapped => :environment do
      sync_tokens = ENV['sync_tokens']
      sync_tokens = sync_tokens.blank? ? [] : sync_tokens.split(',')

      data = {}
      out_str = "sync_token, scheduled, sent, tapped\n"

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens
      ) { |entry, index, sync_token|
        data[sync_token] = {sent: 0, tapped: 0, scheduled: 0} if data[sync_token].blank?
        data[sync_token][:scheduled] += 1 if entry.type == "notificationScheduled"
        data[sync_token][:sent] += 1 if entry.type == "notificationDisplayed"
        data[sync_token][:tapped] += 1 if entry.type == "notificationTapped"
      }

      data.each_pair do |token, value|
        out_str << "#{token}, #{value[:scheduled]}, #{value[:sent]}, #{value[:tapped]}\n"
      end

      write_report(out_str, 'notifications_tapped', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How many times per day are people using locate?"
    task :ranging_begin => :environment do
      sync_tokens = ENV['sync_tokens']
      sync_tokens = sync_tokens.blank? ? [] : sync_tokens.split(',')

      data = {}
      out_str = "date, locate_count\n"

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens
      ) { |entry, index, sync_token|
        date = entry.time.to_date
        data[date] = (data[date] || 0) + 1 if entry.type == "distanceRangingStarted"
      }

      # sort the hash in order of the dates
      data = data.sort_by {|k,v| k}.to_h

      # for every date between the start and the end
      (data.keys.first..data.keys.last).each do |date|
        out_str << "#{date}, #{data[date] || 0}\n"
      end

      write_report(out_str, 'ranging_begin', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "What time of day are users receiving notifications?"
    task :when_notifications => :environment do
      sync_tokens = ENV['sync_tokens']
      sync_tokens = sync_tokens.blank? ? [] : sync_tokens.split(',')

      data = {}
      out_str = "hour, notification_count\n"

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens
      ) { |entry, index, sync_token|
        hour = entry.time.hour
        data[hour] = (data[hour] || 0) + 1 if entry.type == "notificationDisplayed"
      }

      # sort the hash in order of the dates
      data = data.sort_by {|k,v| k}.to_h

      # output times in local hour
      data.each_pair do |hour, value|
        local_hour = Time.parse("#{hour}:00").in_time_zone('Australia/Sydney')
        out_str << "#{local_hour}, #{value}\n"
      end

      write_report(out_str, 'when_notifications', "report_#{Time.now.strftime('%s')}.csv")
    end

    def write_report(out_string, dir, file_name)
      base = 'log/diag'
      file_path = File.join(base, dir, file_name)

      # create the directory if it doesn't exist
      FileUtils.mkdir_p(File.join(base,dir))
      File.open(file_path, 'a+') {|file| file.write(out_string)}
      puts "wrote report to -- #{file_path}"
    end
  end

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
