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

  class DiagnosticFile
    attr_accessor :file_path, :entries

    def initialize(path)
      @file_path = path
      @entries = []

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

  class Entry
      TYPE_NAMES = %w{appLaunched appFailedToGetAPNSToken appReceivedUnknownRemoteNotification appReceivedRemoteNotification appWillResignActive appDidEnterBackground appWillEnterForeground appDidBecomeActive appWillTerminate settingsDeviceDetailsAppear settingsAppear settingsSetNotifyOnDisconnect settingsSetNotifyOnBluetoothUnavailable settingsSetSynchroniseAccount settingsPressHelp settingsPressWebsiteLink settingsPressLegal settingsPressSleep settingsPressUnlink settingsPressLogout settingsPerformingSleep settingsPerformingUnlink settingsPerformingLogout settingsAccountDetailsAppear settingsPressToggleSynchroniseAccount settingsPressAddQuietZone settingsPressExistingQuietZone bleConnected bleReconnected bleDisconnected bleFailedToConnect bleReadPinOK bleReadBattery bleReadRSSI glassesLoc glassesUnlinkSuccessful glassesUnlinkFailed glassesTickDistance glassesHQDistance glassesLowBattery glassesLost locationServicesWarningShown locationServicesWarningShowSettings locationServicesWarningDismiss motionActivityWarningShown motionActivityWarningShowSettings motionActivityWarningDismiss notificationsWarningShown notificationsWarningShowSettings notificationsWarningDismiss userLoc userQuietZone userLogoutSuccessful userLogoutFailed userDidVisit userActivityData userPedometerData notificationScheduled notificationDisplayed notificationCancelled notificationTapped notificationCleared notificationsAvailable rootActive rootInactive expandedDetails collapsedDetails requestedDirections tappedMapPin activeViewActive activeViewInactive bluetoothAvailable bluetoothUnavailable locationAvailable locationUnavailable notificationsUnavailable sensorsAvailable sensorsUnavailable taskComplete missingUploadSessionPath appEnvironment lowPowerState stateMachine requestFailure requestError requestErrorUnavailable distanceRangingStarted distanceRangingStopped distanceRangingMeasurements quietZoneList quietZoneRead quietZoneCreate quietZoneUpdate quietZoneDelete roomList roomRead roomCreate roomUpdate roomDelete quietZoneActiveTimeEnded quietZoneActiveTimeStarted setupDidVistRoot setupDidVistEnableBLE setupDidVisitPower setupDidVisitPIN setupDidVisitLogin setupDidVisitRegister setupDidVisitLinking setupDidVisitPermissions setupDidVisitSuccess betaDidPressFeedback scheduleTriggered syncAppParams syncDevice}

      attr_accessor :ts, :raw_ts, :type, :value, :time

      def initialize(io, prev_ts)
          # we don't need to check io.eof? here as the Block.init loop won't
          # continue and init us if eof is reached. when varint calls io.read(1)
          # it will succeed at least once
          @raw_ts = VarInt.parse(io)
          @ts = @raw_ts + prev_ts
          @time = time.in_time_zone('Australia/Sydney')

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
          time: time.strftime('%l:%M:%S %p'),
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
    # set up the diagnostics environment (don't load any files yet)
    def initialize
      @diagnostics_path = Rails.root.join('diagnostics')
    end

    def parallel_scan_all
      files = Dir[ File.join(@diagnostics_path, '**', '*') ].reject { |p| File.directory? p }

      Parallel.each(files, progress: 'parallel') { |file|
        diag = DiagnosticFile.new(file)
      }

      # Parallel.map(files, progress: 'parallel', in_processes: 4) { |file|
      #   diag = DiagnosticFile.new(file)
      # }
    end

    def entries_for_period(token, date, start_index, end_index)
      entries = []
      filtered_entries = []

      # read out all the entries from every diagnostic file for this day
      paths(token, date).each do |file|
        diagnostic_file = DiagnosticFile.new(file)
        entries.concat(diagnostic_file.entries)
      end

      entries.each_with_index do |entry, index|
        if index > end_index.to_i
          return filtered_entries
        elsif index > start_index.to_i && index < end_index.to_i
          filtered_entries.push(entry)
        end
      end
    end

    # retrieve all the entries for a token on a given date
    # if both a blacklist and a whitelist is provided, it will use the whitelist and ignore the blacklist
    def entries_for_token_date(token, date, whitelist=[], aggregate=[])
      all_entries = []

      # entries will contain a filtered list of entry hashes (once the filters have been applied)
      # aggregates will provide counts for certain events
      data = {
        timeline_items: [],
        aggregates: {}
      }

      # read out all the entries from every diagnostic file for this day
      paths(token, date).each do |file|
        diagnostic_file = DiagnosticFile.new(file)
        all_entries.concat(diagnostic_file.entries)
      end

      # sort all entries
      all_entries.sort_by! { |entry| entry.ts }

      # build all the aggregate values that are required
      data[:aggregates] = build_aggregates(all_entries, aggregate)

      # filter all_entries by the whitelist
      if whitelist.empty?
        # just push all the entries into data with no preceding counts
        data[:timelime_items] = all_entries.map.with_index{ |entry, index| TimelineItem.new(entry, 0, index)}
      else
        # we have a whitelist, so filter the entries and count how many in between
        preceding_count = 0

        all_entries.each_with_index { |entry, index|
          if whitelist.include? entry.type
            data[:timeline_items].push(TimelineItem.new(entry, preceding_count, index))
            # data[:items].push({entry: entry, preceding: preceding_count, index: index})
            preceding_count = 0
          else
            preceding_count += 1
          end
        }
      end

      return data
    end

    def paths(token, date)
      return Dir[File.join(@diagnostics_path, token, date, '*')]
    end

    private

    # given a list of entries and a list of diagnostic keys to aggregate over, build an aggregate hash
    # all aggregate hashes will contain start_time, end_time and total_entries
    def build_aggregates(entries, aggregate)
      aggregated = {}
      # set the basic aggregates
      aggregated[:start_time] = entries.first.time
      aggregated[:end_time] = entries.last.time
      aggregated[:total_entries] = entries.count

      entries.each { |entry|
        aggregated[entry.type] = (aggregated[entry.type] || 0) + 1 if aggregate.include? entry.type
      }

      return aggregated
    end

  end

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

  # ============================
  # ====== entries  ============
  # ============================

  # TODO: more documentation about how this works

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
        {
          confidence: @confidence,
          type: @type,
          ts: @ts
        }
      end
  end

end
