json.success true
json.params do
    json.settings do
        json.details_unknown                            t('app_params.settings.details_unknown')
        json.website_link                               "http://www.tzukuri.com/"
        json.help_link                                  "http://tzukuri.helpscoutdocs.com/"

        # notification cells
        json.notification_left_behind                   t('app_params.settings.notification_left_behind')
        json.notification_bluetooth_disabled            t('app_params.settings.notification_bluetooth_disabled')
        json.notification_header                        t('app_params.settings.notification_header')
        json.notification_footer                        t('app_params.settings.notification_footer')

        # glasses cells
        json.glasses_details                            t('app_params.settings.glasses_details')
        json.glasses_aeroplane_mode                     t('app_params.settings.glasses_aeroplane_mode')
        json.glasses_unlink                             t('app_params.settings.glasses_unlink')
        json.glasses_header                             t('app_params.settings.glasses_header')

        # account cells
        json.account_details                            t('app_params.settings.account_details')
        json.account_synchronise                        t('app_params.settings.account_synchronise')
        json.account_logout                             t('app_params.settings.account_logout')
        json.account_header                             t('app_params.settings.account_header')

        # help cells
        json.help_title                                 t('app_params.settings.help_title')
        json.help_website                               t('app_params.settings.help_website')
        json.help_header                                t('app_params.settings.help_header')

        # quiet zone cells
        json.quiet_zone_title                           t('app_params.settings.quiet_zone_title')
        json.quiet_zone_header                          t('app_params.settings.quiet_zone_header')
        json.quiet_zone_footer                          t('app_params.settings.quiet_zone_footer')
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

        # power
        json.activate_prompt                            t('app_params.setup.activate_prompt')

        # pin entry
        json.enter_pin_prompt                           t('app_params.setup.enter_pin_prompt')
        json.enter_pin_error                            t('app_params.setup.enter_pin_error')

        # register
        json.register_prompt                            t('app_params.setup.register_prompt')
        json.register_name_placeholder                  t('app_params.setup.register_name_placeholder')
        json.register_email_placeholder                 t('app_params.setup.register_email_placeholder')
        json.register_password_placeholder              t('app_params.setup.register_password_placeholder')
        json.register_signup_button                     t('app_params.setup.register_signup_button')
        json.register_login_button                      t('app_params.setup.register_login_button')

        # login
        json.login_prompt                               t('app_params.setup.login_prompt')
        json.login_email_placeholder                    t('app_params.setup.login_email_placeholder')
        json.login_password_placeholder                 t('app_params.setup.login_password_placeholder')
        json.login_register_button                      t('app_params.setup.login_register_button')
        json.login_login_button                         t('app_params.setup.login_login_button')

        # linking
        json.linking_header                             t('app_params.setup.linking_header')

        # permissions
        json.permissions_prompt                         t('app_params.setup.permissions_prompt')
        json.location_services_header                   t('app_params.setup.location_services_header')
        json.location_services_description              t('app_params.setup.location_services_description')
        json.motion_and_fitness_header                  t('app_params.setup.motion_and_fitness_header')
        json.motion_and_fitness_description             t('app_params.setup.motion_and_fitness_description')
        json.notifications_header                       t('app_params.setup.notifications_header')
        json.notifications_description                  t('app_params.setup.notifications_description')
        json.permissions_finished_title                 t('app_params.setup.permissions_finished_title')

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
        json.location_services_warning_enabled          true

        json.notifications_warning_header               t('app_params.warning_screens.notifications_warning_header')
        json.notifications_warning_description          t('app_params.warning_screens.notifications_warning_description')
        json.notifications_warning_dismiss_button       t('app_params.warning_screens.notifications_warning_dismiss_button')
        json.notifications_warning_help_button          t('app_params.warning_screens.notifications_warning_help_button')
        json.notifications_warning_enabled              true

        json.motion_activity_warning_header             t('app_params.warning_screens.motion_activity_warning_header')
        json.motion_activity_warning_description        t('app_params.warning_screens.motion_activity_warning_description')
        json.motion_activity_warning_dismiss_button     t('app_params.warning_screens.motion_activity_warning_dismiss_button')
        json.motion_activity_warning_help_button        t('app_params.warning_screens.motion_activity_warning_help_button')
        json.motion_activity_warning_enabled            true
    end

    json.syncing do
    end

    json.connection do
        json.scan_seconds                               10
        json.reconnect_attempts                         3
        json.coupling_write_pin_timeout                 2
        json.coupling_read_serial_timeout               5
    end

    json.intervals do
        json.location_services_warning                  24.hours.to_i
        json.notifications_warning                      24.hours.to_i
        json.sensors_warning                            24.hours.to_i
        json.app_params_sync                            24.hours.to_i
        json.glasses_params_sync                        24.hours.to_i
        json.device_sync                                24.hours.to_i
        json.location_sync                              15.minutes.to_i
        json.diagnostics_sync                           12.hours.to_i
    end
end
