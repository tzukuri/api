module Tzukuri

  class DiagnosticFile
    attr_accessor :file_path, :entries

    def initialize(path)
      @file_path = path
      @entries = []

      blocks = blocks_from_file(@file_path)

      blocks.each do |block|
        @entries.concat(block.entries)
      end
    end

    private

    def blocks_from_file(file)
      bytes = IO.binread(file)
      io = StringIO.new(bytes)
      blocks = []

      until io.eof?
        begin
          blocks << Tzukuri::Block.new(io)
        rescue
          # ignore invalid blocks
        end
      end

      blocks
    end
  end

  class UserActivityValue
      attr_accessor :ts, :confidence, :type

      def initialize(ts, io)
          @ts = ts
          @confidence, @type = io.read.unpack('CC')
      end

      def time
          epoch = Time.new(2001,1,1,0,0,0,0).to_i
          Time.at(epoch + (@ts / 1000))
      end

      def type_name
          %w{stationary walking running automotive cycling unknown}[type]
      end

      def confidence_name
          %w{low medium high}[@confidence]
      end
  end

  class Entry
      TYPE_NAMES = %w{appLaunched appFailedToGetAPNSToken appReceivedUnknownRemoteNotification appReceivedRemoteNotification appWillResignActive appDidEnterBackground appWillEnterForeground appDidBecomeActive appWillTerminate settingsDeviceDetailsAppear settingsAppear settingsSetNotifyOnDisconnect settingsSetNotifyOnBluetoothUnavailable settingsSetSynchroniseAccount settingsPressHelp settingsPressWebsiteLink settingsPressLegal settingsPressSleep settingsPressUnlink settingsPressLogout settingsPerformingSleep settingsPerformingUnlink settingsPerformingLogout settingsAccountDetailsAppear settingsPressToggleSynchroniseAccount settingsPressAddQuietZone settingsPressExistingQuietZone bleConnected bleReconnected bleDisconnected bleFailedToConnect bleReadPinOK bleReadBattery bleReadRSSI glassesLoc glassesUnlinkSuccessful glassesUnlinkFailed glassesTickDistance glassesHQDistance glassesLowBattery glassesLost locationServicesWarningShown locationServicesWarningShowSettings locationServicesWarningDismiss motionActivityWarningShown motionActivityWarningShowSettings motionActivityWarningDismiss notificationsWarningShown notificationsWarningShowSettings notificationsWarningDismiss userLoc userQuietZone userLogoutSuccessful userLogoutFailed userDidVisit userActivityData userPedometerData notificationScheduled notificationDisplayed notificationCancelled notificationTapped notificationCleared notificationsAvailable rootActive rootInactive expandedDetails collapsedDetails requestedDirections tappedMapPin activeViewActive activeViewInactive bluetoothAvailable bluetoothUnavailable locationAvailable locationUnavailable notificationsUnavailable sensorsAvailable sensorsUnavailable taskComplete missingUploadSessionPath appEnvironment lowPowerState stateMachine requestFailure requestError requestErrorUnavailable distanceRangingStarted distanceRangingStopped distanceRangingMeasurements quietZoneList quietZoneRead quietZoneCreate quietZoneUpdate quietZoneDelete roomList roomRead roomCreate roomUpdate roomDelete quietZoneActiveTimeEnded quietZoneActiveTimeStarted setupDidVistRoot setupDidVistEnableBLE setupDidVisitPower setupDidVisitPIN setupDidVisitLogin setupDidVisitRegister setupDidVisitLinking setupDidVisitPermissions setupDidVisitSuccess betaDidPressFeedback scheduleTriggered syncAppParams syncDevice}
      attr_accessor :ts, :raw_ts, :type, :value

      def initialize(io, prev_ts)
          # we don't need to check io.eof? here as the Block.init loop won't
          # continue and init us if eof is reached. when varint calls io.read(1)
          # it will succeed at least once
          @raw_ts = varint(io)
          @ts = @raw_ts + prev_ts

          @raw_type = io.read(1)
          if @raw_type.nil?
              @type = "INVALID"
              return
          else
              @type = TYPE_NAMES[@raw_type.ord]
          end

          raise 'truncated entry' if io.eof?
          value_length = varint(io)
          @value = io.read(value_length)
          raise 'truncated value data' unless @value.length == value_length
      end

      def time
          epoch = Time.new(2001,1,1,0,0,0,0).to_i # NSDate epoch
          Time.at(epoch + (@ts / 1000))
      end

      def printable_value?
          @type.in?(%w{stateMachine notificationScheduled notificationCancelled notificationDisplayed notificationTapped notificationCleared glassesLost scheduleTriggered glassesLowBattery appEnvironment requestError requestFailure lowPowerState appFailedToGetAPNSToken})
      end

      def varint_value?
          @type.in?(%w{bleReadPinOK bleReadBattery bleReadRSSI})
      end

      def varint_value
          varint(StringIO.new(value))
      end

      def float_value?
          @type.in?(%w{glassesTickDistance glassesHQDistance})
      end

      def float_value
          value.unpack('e')[0]
      end

      def user_activity_value
          if @user_activity_value.nil?
              io = StringIO.new(value)
              ts = varint(io)
              @user_activity_value = UserActivityValue.new(ts, io)
          end
          @user_activity_value
      end

      def varint(io)
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

  class Block
      LITTLE_ENDIAN_32BIT_INT = 'l<'
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
              compressed_length = compressed_length_bytes.unpack(LITTLE_ENDIAN_32BIT_INT)[0]
              raise 'invalid compressed length' if compressed_length.nil? # when compressed_length_bytes.length is < INT_LENGTH
          rescue NoMethodError # when compressed_length_bytes is nil
              raise 'invalid compressed length'
          end

          # parse the 4 byte uncompressed data length int
          data_length_bytes = io.read(INT_LENGTH)
          begin
              data_length = data_length_bytes.unpack(LITTLE_ENDIAN_32BIT_INT)[0]
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
              entry = Tzukuri::Entry.new(data_io, prev_ts)
              @entries << entry
              prev_ts = entry.ts
          end
      end
  end

  class Diagnostics

    # server has 6 sockets at 1 core per socket
    # NUM_PROCESSES = Parallel.processor_count

    # set up the diagnostics environment (don't load any files yet)
    def initialize
      @diagnostics_path = Rails.root.join('diagnostics')
    end

    def parallel_scan_all
      files = Dir[ File.join(@diagnostics_path, '**', '*') ].reject { |p| File.directory? p }

      Parallel.map(files, progress: 'parallel', in_processes: 4) { |file|
        diag = DiagnosticFile.new(file)
      }
    end

    # retrieve all the entries for a token on a given date
    def entries_for_token_date(token, date)
      files = Dir[File.join(@diagnostics_path, token, date, '*')]
      entries = []

      files.each do |file|
        diagnostic_file = Tzukuri::DiagnosticFile.new(file)
        entries.concat(diagnostic_file.entries)
      end

      entries
    end

  end

end
