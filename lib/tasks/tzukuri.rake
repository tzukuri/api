require 'fileutils'
require 'action_view'
require 'action_view/helpers'

include ActionView::Helpers::DateHelper

namespace :tzukuri do

  namespace :diag do

    desc "get a list of users that have a production pair of glasses linked to their account"
    task :prod_users => :environment do
      production_devices = Device.where(hardware_revision: "Rev3E")

      prod_users = []
      production_devices.each do |d|
        prod_users << d.current_owner if !d.current_owner.nil?
      end

      out_str = "name, email\n"

      prod_users.each do |user|
        out_str << "#{user.name}, #{user.email}\n"
      end

      write_report(out_str, "prod_users", "report_#{Time.now.strftime('%s')}.csv")
    end


    desc "get a list of users that have a beta pair of glasses linked to their account"
    task :beta_users => :environment do
      beta_devices = Device.where(hardware_revision: "Beta 😎")

      beta_users = []
      beta_devices.each do |d|
        beta_users << d.current_owner if !d.current_owner.nil?
      end

      out_str = "name, email\n"

      beta_users.each do |user|
        out_str << "#{user.name}, #{user.email}\n"
      end

      write_report(out_str, "beta_users", "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How long does the battery last on a user's glasses?"
    task :battery_readings => :environment do
      sync_tokens, dates = parse_args(ENV)
      abort("exiting, requires token -- sync_token=[sync_token]") if sync_tokens.blank?

      out_str = "time, value\n"

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens
      ) { |entry|
        out_str << "#{entry.time}, #{entry.value.to_i}\n" if entry.type == "bleReadBattery"
      }

      write_report(out_str, 'battery_readings', "report_#{Time.now.strftime('%s')}_#{sync_tokens}.csv")
    end

    desc "How many times per day do user's open the app?"
    task :app_opens => :environment do
      sync_tokens, dates = parse_args(ENV)
      data = {}

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens,
        dates: dates,
        entry_types: ['appDidBecomeActive'],
        filter_tz: true
      ) { |entry, index, sync_token|
          data[entry.time.to_date] = (data[entry.time.to_date] || 0) + 1
      }

      # sort the hash in order of the dates
      data = data.sort_by {|k,v| k}.to_h

      out_str = "date, num_opens\n"
      (data.keys.first..data.keys.last).each do |date|
        out_str << "#{date}, #{data[date] || 0}\n"
      end

      write_report(out_str, 'app_opens', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How often do users interact with notifications?"
    task :notifications_tapped => :environment do
      sync_tokens, dates = parse_args(ENV)
      data = {}

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens,
        dates: dates,
        entry_types: ['notificationScheduled', 'notificationDisplayed', 'notificationTapped'],
        filter_tz: true
      ) { |entry, index, sync_token|
        data[sync_token] = {sent: 0, tapped: 0, scheduled: 0} if data[sync_token].blank?
        data[sync_token][:scheduled] += 1 if entry.type == "notificationScheduled"
        data[sync_token][:sent] += 1 if entry.type == "notificationDisplayed"
        data[sync_token][:tapped] += 1 if entry.type == "notificationTapped"
      }

      out_str = "sync_token, scheduled, sent, tapped\n"
      data.each_pair do |token, value|
        out_str << "#{token}, #{value[:scheduled]}, #{value[:sent]}, #{value[:tapped]}\n"
      end

      write_report(out_str, 'notifications_tapped', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How many times per day are people using locate?"
    task :ranging_begin => :environment do
      sync_tokens, dates = parse_args(ENV)
      data = {}

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens,
        dates: dates,
        entry_types: ['distanceRangingStarted'],
        filter_tz: true
      ) { |entry, index, sync_token|
        date = entry.time.to_date
        data[date] = (data[date] || 0) + 1
      }

      # sort the hash in order of the dates
      data = data.sort_by {|k,v| k}.to_h

      out_str = "date, locate_count\n"
      (data.keys.first..data.keys.last).each do |date|
        out_str << "#{date}, #{data[date] || 0}\n"
      end

      write_report(out_str, 'ranging_begin', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "What time of day are users recieving notifications?"
    task :when_notifications => :environment do
      sync_tokens, dates = parse_args(ENV)
      data = {}

      Tzukuri::Diagnostics.analyse(
        sync_tokens: sync_tokens,
        dates: dates,
        entry_types: ['notificationDisplayed'],
        filter_tz: true
      ) { |entry, index, sync_token|
        data[entry.time.hour] = (data[entry.time.hour] || 0) + 1
      }

      out_str = "hour, notification_count\n"

      data.each_pair do |hour, value|
        out_str << "#{Time.parse("#{hour}:00").in_time_zone('Australia/Sydney')}, #{value}\n"
      end

      write_report(out_str, 'when_notifications', "report_#{Time.now.strftime('%s')}.csv")
    end

    desc "How long since each user's glasses have connected?"
    task :last_seen => :environment do
      out_str = "user, device, coords, state\n"
      User.all.each do |user|
        user.devices.each do |device|
          coords = device.coords_set_time.blank? ? 'Unknown' : time_ago_in_words(device.coords_set_time)
          state = device.state_set_time.blank? ? 'Unknown' : time_ago_in_words(device.state_set_time)
          out_str << "#{user.name}, #{device.pin}, #{coords}, #{state}\n"
        end
      end

      write_report(out_str, 'last_seen', "report_#{Time.now.strftime('%s')}.csv")
    end

    private

    def parse_args(env)
      sync_tokens = env['sync_tokens']
      dates = env['dates']

      sync_tokens = sync_tokens.blank? ? [] : sync_tokens.split(',')
      dates = dates.blank? ? [] : dates.split(',')

      return sync_tokens, dates
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

  desc "Update all serials that were incorrectly beginning with 60D2620"
  task :update_serials => :environment do

    incorrect_serials = Device.where("serial LIKE ?", "%60D2620%")

    incorrect_serials.each do |device|
      mac = device.mac_address
      new_serial = mac[0..5] + "FFFE" + mac[6..11]

      device.update_attribute('serial', new_serial)
    end
  end

  # desc "Make sure there is a device for all generated PINs"
  # task :generate_devices => :environment do
  #   generated_pins = Set.new([838162,846944,841149,846498,813581,807150,875778,895482,856815,864789,802310,852252,843752,806121,896894,836216,866719,827634,867557,832146,872270,891743,877485,873462,885825,883233,885982,866581,827025,849122,826138,859130,894509,887949,858444,816206,843888,825664,887375,135139,119172,150433,132167,196282,179324,149842,153871,113909,147616,134873,118475,167302,153902,197529,191824,119805,108631,111031,155435,178834,155721,171317,116619,165882,146981,195355,155436,191399,180332,164375,131523,160587,112544,128742,196990,189157,110280,188120,154838,166120,112829,179198,146677,163782,155841,120243,103474,109324,165962,161580,130748,123852,195975,151423,120133,108245,134050,153208,169596,140232,126579,100042,131187,120070,149114,168547,158400,130252,176113,111309,154883,117527,159962,144777,174473,144553,132135,196110,125563,190796,170894,147246,170194,175723,148138,178993,142456,168608,113981,166691,162467,190075,106437,181051,191957,174395,165764,155945,192816,183004,106511,109976,144557,197154,155383,140583,143294,190927,189400,110814,191747,131450,108574,174424,181513,151551,157635,109080,156997,135841,124176,126087,192171,129201,189225,141820,198067,178549,155809,148381,179717,122093,182109,162583,157894,166825,109720,181503,144465,145058,155940,193308,131647,113978,196778,163825,113243,100574,113872,183852,129634,192490,133797,149421,107539,185923,187530,164272,120967,188436,110881,135748,152701,140092,120550,112591,190759,186756,129391,185474,132271,103372,168963,119926,119220,132023,195501,122472,189076,119432,112504,134185,124664,173705,136680,136742,126968,121401,180028,104062,121802,195105,111684,112109,169852,133554,149363,170833,128200,178190,195442,133482,185118,130052,159592,132180,134816,197565,136852,137374,113175,161675,180400,156668,130294,194923,192521,193895,132133,116815,119625,166415,157938,121232,107126,110562,176837,162193,124258,134928,128683,191558,173471,163000,109344,167813,178387,122510,144387,128448,146432,149995,102593,123747,147163,147819,161558,181252,165614,156966,158192,184140,171600,138352,192821,188004,157899,194469,113454,123023,139859,133076,115817,169722,114101,186559,125189,123815,146692,138867,153811,124154,171183,124618,176880,146686,109726,159050,108602,143760,148893,186774,124754,112802,122380,110835,188394,141710,115122,116180,111685,141389,184432,189546,189298,178330,185241,183498,196157,155836,147870,164071,153256,119142,143359,162069,110153,118141,168692,101700,142281])
  #   api_devices = Set.new(Device.all.map(&:pin))
  #
  #   # PINs that have been generated but not entered into the API
  #   unassigned_pins = generated_pins - api_devices
  #   last_mac = Device.where("mac_address ~* ?", '60D262.').map(&:mac_address).max_by { |mac| mac.to_i(16) }
  #
  #   unassigned_pins.each do |pin|
  #     # create a device for this PIN
  #     last_mac = (last_mac.to_i(16) + MAC_INCREMENT).to_s(16).upcase
  #     serial = last_mac[0..6] + "FFFE" + last_mac[6..11]
  #
  #     puts "generating -- #{last_mac}, #{pin}"
  #     Device.create(mac_address: last_mac, serial: serial, pin: pin)
  #   end
  # end

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
