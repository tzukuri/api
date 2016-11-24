module Tzukuri
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
        TYPE_NAMES = %w{appLaunched appFailedToGetAPNSToken appReceivedUnknownRemoteNotification appReceivedRemoteNotification appWillResignActive appDidEnterBackground appWillEnterForeground appDidBecomeActive appWillTerminate settingsDeviceDetailsAppear settingsAppear settingsSetNotifyOnDisconnect settingsSetNotifyOnBluetoothUnavailable settingsSetSynchroniseAccount settingsPressHelp settingsPressWebsiteLink settingsPressLegal settingsPressSleep settingsPressUnlink settingsPressLogout settingsPerformingSleep settingsPerformingUnlink settingsPerformingLogout settingsAccountDetailsAppear settingsPressToggleSynchroniseAccount settingsPressAddQuietZone settingsPressExistingQuietZone bleConnected bleReconnected bleDisconnected bleFailedToConnect bleReadPinOK bleReadBattery bleReadRSSI glassesLoc glassesUnlinkSuccessful glassesUnlinkFailed glassesTickDistance glassesHQDistance glassesLowBattery glassesLost locationServicesWarningShown locationServicesWarningShowSettings locationServicesWarningDismiss motionActivityWarningShown motionActivityWarningShowSettings motionActivityWarningDismiss notificationsWarningShown notificationsWarningShowSettings notificationsWarningDismiss userLoc userQuietZone userLogoutSuccessful userLogoutFailed userDidVisit userActivityData userPedometerData notificationScheduled notificationDisplayed notificationCancelled notificationTapped notificationCleared notificationsAvailable rootActive rootInactive expandedDetails collapsedDetails requestedDirections tappedMapPin activeViewActive activeViewInactive bluetoothAvailable bluetoothUnavailable locationAvailable locationUnavailable notificationsUnavailable sensorsAvailable sensorsUnavailable taskComplete missingUploadSessionPath appEnvironment lowPowerState stateMachine requestFailure requestError requestErrorUnavailable distanceRangingStarted distanceRangingStopped distanceRangingMeasurements quietZoneList quietZoneRead quietZoneCreate quietZoneUpdate quietZoneDelete roomList roomRead roomCreate roomUpdate roomDelete quietZoneActiveTimeEnded quietZoneActiveTimeStarted setupDidVistRoot setupDidVistEnableBLE setupDidVisitPower setupDidVisitPIN setupDidVisitLogin setupDidVisitRegister setupDidVisitLinking setupDidVisitPermissions setupDidVisitSuccess betaDidPressFeedback scheduleTriggered syncAppParams syncDevice lowMemory missingConnection locError uploadFailed calibrateStart calibrateStop channelAssessment}
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

        def channel_rssi_measurement_value
            value.unpack('Cc')
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
end
