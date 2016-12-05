ActiveAdmin.register_page "Diagnostics" do
  controller do

    # show a list of the authentication tokens
    def devices
      path = Rails.root.join('diagnostics')
      tokens = Dir.entries(path) - ['.', '..', 'NO_AUTH_TOKEN']
      @auth_tokens = AuthToken.where(diagnostics_sync_token: tokens).all

      # set the active admin page title
      @page_title = "Authentication Tokens"
    end

    # show a list of all the dates for an authentication token
    def dates
      @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
      path = Rails.root.join('diagnostics', params[:token])
      @dates = Dir.entries(path) - ['.', '..', '.DS_Store']
      @dates.sort!

      @file_count = {}

      @dates.each do |date|
        path = Rails.root.join('diagnostics', params[:token], date)
        files = Dir.entries(path) - ['.', '..', '.DS_Store']
        @file_count[date] = files.count
      end

      @sync_token = @auth_token.blank? ? params[:token] : @auth_token.diagnostics_sync_token
      @page_title = "#{@auth_token.api_device.name}" unless @auth_token.blank?
    end

    # list all the files for a given date
    def files
        @auth_token = AuthToken.find_by_diagnostics_sync_token(params[:token])
        @user = @auth_token.user unless @auth_token.blank?

        @type_names = %w{appLaunched appFailedToGetAPNSToken appReceivedUnknownRemoteNotification appReceivedRemoteNotification appWillResignActive appDidEnterBackground appWillEnterForeground appDidBecomeActive appWillTerminate settingsDeviceDetailsAppear settingsAppear settingsSetNotifyOnDisconnect settingsSetNotifyOnBluetoothUnavailable settingsSetSynchroniseAccount settingsPressHelp settingsPressWebsiteLink settingsPressLegal settingsPressSleep settingsPressUnlink settingsPressLogout settingsPerformingSleep settingsPerformingUnlink settingsPerformingLogout settingsAccountDetailsAppear settingsPressToggleSynchroniseAccount settingsPressAddQuietZone settingsPressExistingQuietZone bleConnected bleReconnected bleDisconnected bleFailedToConnect bleReadPinOK bleReadBattery bleReadRSSI glassesLoc glassesUnlinkSuccessful glassesUnlinkFailed glassesTickDistance glassesHQDistance glassesLowBattery glassesLost locationServicesWarningShown locationServicesWarningShowSettings locationServicesWarningDismiss motionActivityWarningShown motionActivityWarningShowSettings motionActivityWarningDismiss notificationsWarningShown notificationsWarningShowSettings notificationsWarningDismiss userLoc userQuietZone userLogoutSuccessful userLogoutFailed userDidVisit userActivityData userPedometerData notificationScheduled notificationDisplayed notificationCancelled notificationTapped notificationCleared notificationsAvailable rootActive rootInactive expandedDetails collapsedDetails requestedDirections tappedMapPin activeViewActive activeViewInactive bluetoothAvailable bluetoothUnavailable locationAvailable locationUnavailable notificationsUnavailable sensorsAvailable sensorsUnavailable taskComplete missingUploadSessionPath appEnvironment lowPowerState stateMachine requestFailure requestError requestErrorUnavailable distanceRangingStarted distanceRangingStopped distanceRangingMeasurements quietZoneList quietZoneRead quietZoneCreate quietZoneUpdate quietZoneDelete roomList roomRead roomCreate roomUpdate roomDelete quietZoneActiveTimeEnded quietZoneActiveTimeStarted setupDidVistRoot setupDidVistEnableBLE setupDidVisitPower setupDidVisitPIN setupDidVisitLogin setupDidVisitRegister setupDidVisitLinking setupDidVisitPermissions setupDidVisitSuccess betaDidPressFeedback scheduleTriggered syncAppParams syncDevice lowMemory missingConnection locError uploadFailed calibrateStart calibrateStop channelAssessment}

        # extract filter types from params (if provided)
        @filter_types = params[:filter].split(',') if !params[:filter].blank?
        default_types = ['stateMachine', 'appEnvironment', 'notificationDisplayed', 'notificationScheduled', 'appDidBecomeActive', 'bleDisconnected', 'bleConnected']

        # user filter types if they exist, otherwise just show default
        whitelist = @filter_types.blank? ? default_types : @filter_types

        @data = Tzukuri::Diagnostics.entries_for_token_date(params[:token], params[:date], whitelist,
            # aggregate entry types (count)
            ['appDidBecomeActive', 'notificationDisplayed', 'bleDisconnected']
        )

        start_time = @data[:aggregates][:start_time].in_time_zone('Australia/Sydney')
        end_time = @data[:aggregates][:end_time].in_time_zone('Australia/Sydney')
        time = start_time

        @hours = []

        while time.hour != end_time.hour || time.day != end_time.day
          @hours << time.hour
          time = time.in(1.hour)
        end

        @page_title = "#{@auth_token.api_device.name} / #{params[:date]}" unless @auth_token.blank?
    end

    def expand
      entries = Tzukuri::Diagnostics.entries_between_index(params[:token], params[:date], params[:start_index], params[:end_index])
      render json: {success: true, count: entries.count, entries: entries}
    end

  end
end
