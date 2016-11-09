module Tzukuri
  # ruby unpack format strings http://apidock.com/ruby/String/unpack
  LITTLE_ENDIAN_INT_32 = 'l<'
  LITTLE_ENDIAN_UINT_32 = 'L<'
  LITTLE_ENDIAN_UINT_16 = 'S<'
  LITTLE_ENDIAN_DOUBLE = 'E'

  class VarInt
    def self.parse(io)
      number = 0
      n = 0

      while true
          byte = io.read(1)
          return number if byte.nil?
          byte = byte.ord

          # if msb is set, continue reading
          more = byte >> 7

          # number is little endian encoded, so the first byte
          # encodes bits 0-6, the second byte 7-13 and so on.
          # we need to remove the msb, and shift the byte so it
          # represents the correct bits in the number
          byte &= 0x7F # AND mask remove the msb
          number += byte << (7 * n)
          n += 1

          return number unless more == 1
      end
    end
  end

  # represents a diagnostics file, handles opening and reading the file as well
  # as construction blocks, entries, etc.
  class DiagnosticFile
    attr_accessor :file_path, :entries, :sync_token

    def initialize(path)
      @file_path = path
      @entries = []
      # extract the sync token
      @sync_token = File.expand_path("../..", @file_path).split('/').last

      blocks_from_file(@file_path).each do |block|
        @entries.concat(block.entries)
      end
    end

    private

    # read the file block by block, returns an array of blocks
    def blocks_from_file(file)
      bytes = IO.binread(file)
      io = StringIO.new(bytes)
      blocks = []

      until io.eof?
        begin
          blocks << Block.new(io)
        rescue
          # ignore invalid blocks
        end
      end

      blocks
    end
  end

  # represents a block of entries within a diagnostics file
  class Block
      INT_LENGTH = 4
      HEADER = 'TZUD'

      attr_reader :entries

      def initialize(io)
          @entries = []

          # ensure we're starting on a block boundary
          header = io.read(HEADER.length)
          raise 'invalid block boundary' unless header == HEADER

          # parse the 4 byte compressed data length int
          compressed_length_bytes = io.read(INT_LENGTH)
          begin
              compressed_length = compressed_length_bytes.unpack(LITTLE_ENDIAN_INT_32)[0]
              raise 'invalid compressed length' if compressed_length.nil? # when compressed_length_bytes.length is < INT_LENGTH
          rescue NoMethodError # when compressed_length_bytes is nil
              raise 'invalid compressed length'
          end

          # parse the 4 byte uncompressed data length int
          data_length_bytes = io.read(INT_LENGTH)
          begin
              data_length = data_length_bytes.unpack(LITTLE_ENDIAN_INT_32)[0]
              raise 'invalid data length' if data_length.nil?
          rescue NoMethodError
              raise 'invalid data length'
          end

          # capture the compressed block data
          compressed = io.read(compressed_length)
          raise 'truncated compressed data' unless compressed.length == compressed_length

          # decompress and sanity check
          data, length = LZ4::Raw.decompress(compressed, data_length)
          raise 'truncated raw data' unless data.length == data_length

          # parse each entry
          data_io = StringIO.new(data)
          prev_ts = 0
          until data_io.eof?
              entry = Entry.new(data_io, prev_ts)
              @entries << entry
              prev_ts = entry.ts
          end
      end
  end

  # represents a single entry within a block, the actual entry data is contained within .value
  class Entry
      TYPE_NAMES = %w{appLaunched appFailedToGetAPNSToken appReceivedUnknownRemoteNotification appReceivedRemoteNotification appWillResignActive appDidEnterBackground appWillEnterForeground appDidBecomeActive appWillTerminate settingsDeviceDetailsAppear settingsAppear settingsSetNotifyOnDisconnect settingsSetNotifyOnBluetoothUnavailable settingsSetSynchroniseAccount settingsPressHelp settingsPressWebsiteLink settingsPressLegal settingsPressSleep settingsPressUnlink settingsPressLogout settingsPerformingSleep settingsPerformingUnlink settingsPerformingLogout settingsAccountDetailsAppear settingsPressToggleSynchroniseAccount settingsPressAddQuietZone settingsPressExistingQuietZone bleConnected bleReconnected bleDisconnected bleFailedToConnect bleReadPinOK bleReadBattery bleReadRSSI glassesLoc glassesUnlinkSuccessful glassesUnlinkFailed glassesTickDistance glassesHQDistance glassesLowBattery glassesLost locationServicesWarningShown locationServicesWarningShowSettings locationServicesWarningDismiss motionActivityWarningShown motionActivityWarningShowSettings motionActivityWarningDismiss notificationsWarningShown notificationsWarningShowSettings notificationsWarningDismiss userLoc userQuietZone userLogoutSuccessful userLogoutFailed userDidVisit userActivityData userPedometerData notificationScheduled notificationDisplayed notificationCancelled notificationTapped notificationCleared notificationsAvailable rootActive rootInactive expandedDetails collapsedDetails requestedDirections tappedMapPin activeViewActive activeViewInactive bluetoothAvailable bluetoothUnavailable locationAvailable locationUnavailable notificationsUnavailable sensorsAvailable sensorsUnavailable taskComplete missingUploadSessionPath appEnvironment lowPowerState stateMachine requestFailure requestError requestErrorUnavailable distanceRangingStarted distanceRangingStopped distanceRangingMeasurements quietZoneList quietZoneRead quietZoneCreate quietZoneUpdate quietZoneDelete roomList roomRead roomCreate roomUpdate roomDelete quietZoneActiveTimeEnded quietZoneActiveTimeStarted setupDidVistRoot setupDidVistEnableBLE setupDidVisitPower setupDidVisitPIN setupDidVisitLogin setupDidVisitRegister setupDidVisitLinking setupDidVisitPermissions setupDidVisitSuccess betaDidPressFeedback scheduleTriggered syncAppParams syncDevice}

      attr_accessor :ts, :raw_ts, :type, :value, :syd_time

      def initialize(io, prev_ts)
          # we don't need to check io.eof? here as the Block.init loop won't
          # continue and init us if eof is reached. when varint calls io.read(1)
          # it will succeed at least once
          @raw_ts = VarInt.parse(io)
          @ts = @raw_ts + prev_ts

          @raw_type = io.read(1)
          if @raw_type.nil?
              @type = "INVALID"
              return
          else
              @type = TYPE_NAMES[@raw_type.ord]
          end

          raise 'truncated entry' if io.eof?
          value_length = VarInt.parse(io)

          data = io.read(value_length)

          @value = ValueFactory.build(data, @type)
          raise 'truncated value data' unless @value.length == value_length
      end

      def time
          epoch = Time.new(2001,1,1,0,0,0,0).to_i # NSDate epoch
          Time.at(epoch + (@ts / 1000))
      end

      def as_json(options={})
        {
          class: @value.class.name,
          time: time.in_time_zone('Australia/Sydney').strftime('%l:%M:%S %p'),
          type: @type,
          value: @value
        }
      end

      def to_partial_path
        # the partial for each entry should be determined by the value type
        @value.to_partial_path
      end
  end

  class Diagnostics
    # handles retrieving filtering files and then handing either the file or the entry off to a block
    def self.analyse(sync_tokens: [], dates: [])
      # get all diagnostic files
      file_paths = Dir[ File.join(Rails.root.join('diagnostics'), '**', '*') ].reject {|path| File.directory? path}

      # LOGGING
      puts "-- ANALYSING DIAGNOSTICS --"
      puts "Tokens: #{sync_tokens.join(', ')}" if sync_tokens.count > 0
      puts "Dates: #{dates.join(', ')}" if dates.count > 0

      # filter any paths that don't match sync tokens or dates
      file_paths.reject! {|path| !sync_tokens.any? {|token| path.include? token} } if sync_tokens.count > 0
      file_paths.reject! {|path| !dates.any? {|date| path.include? date} } if dates.count > 0

      progress_bar = ProgressBar.create(:format => '%a |%b>>%i| %p%% %t', :starting_at => 0, :total => file_paths.count)

      file_paths.each do |file_path|
        file = DiagnosticFile.new(file_path)
        file.entries.each_with_index do |entry, index|
          yield entry, index, file.sync_token
        end
        progress_bar.increment
      end
    end

    # return all the entries between two indexes in a given token and date combination
    def self.entries_between_index(token, date, start_index, end_index)
      filtered_entries = []

      analyse(
        by_entry: true,
        sync_tokens: [token],
        dates: [date]
      ) { |entry, index|
          if index > end_index.to_i
            return filtered_entries
          elsif index > start_index.to_i && index < end_index.to_i
            filtered_entries << entry
          end
      }
    end

    # return all the entries for a given token and date combination
    # as well as some aggregate counts for certain events
    def self.entries_for_token_date(token, date, whitelist=[], aggregate=[])
      entry_count = 0
      preceding_count = 0
      all_entries = []
      data = {
        timeline_items: [],
        aggregates: {
          total_entries: 0,
          start_time: nil,
          end_time:nil
        }
      }

      analyse(
        by_entry: true,
        sync_tokens: [token],
        dates: [date]
      ) { |entry, index|
        all_entries << entry

        if whitelist.blank?
          data[:timeline_items] << TimelineItem.new(entry, 0, index)
        else
          if whitelist.include? entry.type
            data[:timeline_items] << TimelineItem.new(entry, preceding_count, index)
            preceding_count = 0
          else
            preceding_count += 1
          end
        end

        # update the custom aggregates
        data[:aggregates][entry.type] = (data[:aggregates][entry.type] || 0) + 1 if aggregate.include? entry.type
      }

      data[:aggregates][:start_time] = all_entries.first.time
      data[:aggregates][:end_time] = all_entries.last.time
      data[:aggregates][:total_entries] = all_entries.count

      return data
    end

    # return all the blocks for a given file
    def self.blocks_for_file(bytes)
      io = StringIO.new(bytes)
      blocks = []

      until io.eof?
          begin
              blocks << Block.new(io)
          rescue
              # ignore invalid blocks
          end
      end

      return blocks
    end
  end

  # TimelineItems are used in the diagnostics UI to give more context
  # to an entry (how many entries before it and its index in the timeline)
  class TimelineItem
    attr_accessor :entry, :preceding, :index

    def initialize(entry, preceding, index)
      @entry = entry
      @preceding = preceding
      @index = index
    end

    def preceding?
      return @preceding > 0
    end

    def to_partial_path
      @entry.to_partial_path
    end
  end

  # each entry value should have a base class of EntryValue that defines a standard way to interact with an entry
  # EntryValues can then be decorated with any decoding functionality or output functionality (json, strings, partial paths, etc.)
  # EntryValues can easily be created through ValueFactory.build which will decide what type an entry should be and then pass decoding off to the relevant subclass
  class ValueFactory
    # arrays that describe which type should be created, anything not in an array will return as an EntryValue
    STRINGS = %w{notificationScheduled notificationCancelled notificationDisplayed notificationTapped notificationCleared glassesLost scheduleTriggered glassesLowBattery appEnvironment requestError requestFailure lowPowerState appFailedToGetAPNSToken}
    VARINTS = %w{bleReadPinOK bleReadBattery bleReadRSSI}
    FLOATS = %w{glassesTickDistance glassesHQDistance}
    LOCATIONS = %w{glassesLoc userLoc}

    def self.build(data, type)
      # string values
      return StringValue.new(data) if type.in?(STRINGS)
      # varint values
      return VarIntValue.new(data) if type.in?(VARINTS)
      # float values
      return FloatValue.new(data) if type.in?(FLOATS)
      # location values
      return LocationValue.new(data) if type.in?(LOCATIONS)
      # activity values
      return ActivityValue.new(data) if type == "userActivityData"
      # state machine
      return StateMachineValue.new(data) if type == "stateMachine"
      # default value
      return EntryValue.new(data)
    end

  end

  # ------ entry values ------

  class EntryValue
    def initialize(data)
      @raw = data
    end

    def length
      @raw.length
    end

    def to_s
      ""
    end

    def as_json(options={})
      {}
    end

    def to_partial_path
      "entry_generic"
    end
  end

  class StateMachineValue < EntryValue
    attr_accessor :machine, :event, :from, :to

    def initialize(data)
      super(data)
      machine = data.split(":")

      @machine, @event = machine[0].split("-")
      @from, @to = machine[1].split(">")
    end

    def to_s
      "#{machine} -- #{from} >> #{to}"
    end

    def as_json(options={})
      {
        machine: @machine,
        event: @event,
        from: @from,
        to: @to
      }
    end

    def to_partial_path
      "entry_state_machine"
    end
  end

  class StringValue < EntryValue
    def initialize(data)
      super(data)
      @data = data
    end

    def to_s
      @data
    end

    def as_json(options={})
      @data
    end
  end

  class VarIntValue < EntryValue
    def initialize(data)
      super(data)
      @data = VarInt.parse(StringIO.new(data))
    end

    def to_i
      @data.to_i
    end

    def to_s
      @data.to_s
    end

    def as_json(options={})
      @data
    end
  end

  class FloatValue < EntryValue
    def initialize(data)
      super(data)
      @data = data.unpack('e')[0]
    end

    def to_s
      @data.to_s
    end

    def as_json(options={})
      @data
    end
  end

  class LocationValue < EntryValue
    attr_accessor :ts, :latitude, :longitude, :accuracy

    def initialize(data)
      super(data)
      io = StringIO.new(data)
      ## data format [coordinate (8 bytes) | accuracy (8 bytes) | timestamp (<= 9 bytes)]
      ## coordinate format [gridRef (2 bytes) | latOffset (3 bytes | lonOffset (3 bytes))]

      # read the grid reference from the first two bytes
      gridRef = io.read(2).unpack(LITTLE_ENDIAN_UINT_16)[0]

      # read the lat/lon fractional components
      # each one is padded with an empty byte (so we can unpack as a uint_32)
      latBytes = io.read(3) << 0x000000
      lonBytes = io.read(3) << 0x000000

      # unpack the byte strings and divide to restore the fractional component
      latOffset = latBytes.unpack(LITTLE_ENDIAN_UINT_32)[0] / 10_000_000.0
      lonOffset = lonBytes.unpack(LITTLE_ENDIAN_UINT_32)[0] / 10_000_000.0

      # divide the grid reference by 360 to get the 'row' in the coordinate grid, subtract 90 to retrieve the real coordinate
      @latitude = ((gridRef / 360) - 90) - latOffset
      # mod by 360 to get the 'column' in the grid, subtract 180 to retrieve the real coordinate
      @longitude = ((gridRef % 360) - 180) + lonOffset
      # fixme: a rounding error in the encoding appears to offset latitude by +1 in the southern hemisphere
      @latitude += 1 if (latitude < 0)

      # unpack the accuracy as a double
      @accuracy = io.read(8).unpack(LITTLE_ENDIAN_DOUBLE)[0]

      # let varint handle the remainder of the bytes (up to 9) to retrieve the timestamp
      @ts = VarInt.parse(io)
    end

    def timestamp
      epoch = Time.new(2001,1,1,0,0,0,0).to_i # NSDate epoch
      Time.at(epoch + (@ts / 1000))
    end

    def to_s
      "[#{latitude}, #{longitude}] | accuracy: #{accuracy} | ts: #{timestamp.in_time_zone('Australia/Sydney').strftime('%l:%M:%S %p')}"
    end

    def as_json(options={})
      {
        latitude: @latitude,
        longitude: @longitude,
        accuracy: @accuracy,
        ts: timestamp.in_time_zone('Australia/Sydney').strftime('%l:%M:%S %p')
      }
    end

    def to_partial_path
      "entry_location"
    end
  end

  class ActivityValue < EntryValue
      attr_accessor :ts, :confidence, :type

      def initialize(data)
        super(data)
        io = StringIO.new(data)
        @ts = VarInt.parse(io)
        @confidence, @type = io.read.unpack('CC')
      end

      def type_name
        %w{stationary walking running automotive cycling unknown}[type]
      end

      def confidence_name
        %w{low medium high}[@confidence]
      end

      def to_s
        "#{type_name} (confidence: #{confidence_name})"
      end

      def as_json(options={})
        self.to_s
      end
  end
end
