json.success true
json.params do
    json.settings do
        json.website_link                               "http://www.tzukuri.com/"
        json.help_link                                  "http://tzukuri.helpscoutdocs.com/"
        json.sleeping_on_text                           t('app_params.settings.sleeping_on_text')
        json.sleeping_off_text                          t('app_params.settings.sleeping_off_text')
        json.details_unknown                            t('app_params.settings.details_unknown')
    end
    
    json.map do
        json.pin_title                                  t('app_params.map.pin_title')
        json.pin_subtitle                               t('app_params.map.pin_subtitle')
        json.latitude_delta                             0.003271
        json.longitude_delta                            0.004705
    end

    json.hud_titles do
        json.logging_in                                 t('app_params.hud_titles.logging_in')
        json.connecting                                 t('app_params.hud_titles.connecting')
        json.registering                                t('app_params.hud_titles.registering')
    end

    json.alerts do
        json.sleep_fail_title                           t('app_params.alerts.sleep_fail_title')
        json.sleep_fail_message                         t('app_params.alerts.sleep_fail_message')

        json.sleep_title                                t('app_params.alerts.sleep_title')
        json.sleep_message                              t('app_params.alerts.sleep_message')

        json.unlink_title                               t('app_params.alerts.unlink_title')
        json.unlink_message                             t('app_params.alerts.unlink_message')

        json.logout_title                               t('app_params.alerts.logout_title')
        json.logout_message                             t('app_params.alerts.logout_message')

        json.password_mismatch_title                    t('app_params.alerts.password_mismatch_title')
        json.password_mismatch_message                  t('app_params.alerts.password_mismatch_message')

        json.registration_failed_title                  t('app_params.alerts.registration_failed_title')
        json.invalid_registration_message               t('app_params.alerts.invalid_registration_message')
        json.login_failed_title                         t('app_params.alerts.login_failed_title')

        json.unreachable_message                        t('app_params.alerts.unreachable_message')
        json.unknown_error_message                      t('app_params.alerts.unknown_error_message')
    end

    json.notifications do
        json.low_battery                                t('app_params.notifications.low_battery')
        json.left_behind                                t('app_params.notifications.left_behind')
        json.bluetooth_unavailable                      t('app_params.notifications.bluetooth_unavailable')
    end

    json.setup do
        json.forgot_password_link                       "http://account.tzukuri.com/users/password/new"
    end

    json.warning_screens do
        json.warning_help_url                           "http://www.tzukuri.com/"

        json.bluetooth_warning_line_1                   t('app_params.warning_screens.bluetooth_warning_line_1')
        json.bluetooth_warning_line_2                   t('app_params.warning_screens.bluetooth_warning_line_2')
        json.bluetooth_warning_enabled                  true
        
        json.location_services_warning_header           t('app_params.warning_screens.location_services_warning_header')
        json.location_services_warning_description      t('app_params.warning_screens.location_services_warning_description')
        json.location_services_warning_dismiss_button   t('app_params.warning_screens.location_services_warning_dismiss_button')
        json.location_services_warning_help_button      t('app_params.warning_screens.location_services_warning_help_button')
        json.max_location_services_warning_frequency    24.hours.to_i
        json.location_services_warning_enabled          true

        json.notifications_warning_header               t('app_params.warning_screens.notifications_warning_header')
        json.notifications_warning_description          t('app_params.warning_screens.notifications_warning_description')
        json.notifications_warning_dismiss_button       t('app_params.warning_screens.notifications_warning_dismiss_button')
        json.notifications_warning_help_button          t('app_params.warning_screens.notifications_warning_help_button')
        json.max_motion_activity_warning_frequency      24.hours.to_i
        json.notifications_warning_enabled              true

        json.motion_activity_warning_header             t('app_params.warning_screens.motion_activity_warning_header')
        json.motion_activity_warning_description        t('app_params.warning_screens.motion_activity_warning_description')
        json.motion_activity_warning_dismiss_button     t('app_params.warning_screens.motion_activity_warning_dismiss_button')
        json.motion_activity_warning_help_button        t('app_params.warning_screens.motion_activity_warning_help_button')
        json.max_notifications_warning_frequency        24.hours.to_i
        json.motion_activity_warning_enabled            true
    end

    json.syncing do
        json.location_sync_interval                     15.minutes.to_i
        json.diagnostics_sync_interval                  24.hours.to_i
    end

    json.connection do
        json.scan_seconds                               10
        json.reconnect_attempts                         3
        json.coupling_read_serial_timeout               5
    end
end
