ActiveAdmin.register User do
    menu parent: 'API'

    permit_params :email, :password, :password_confirmation, :name

    index do
        selectable_column
        id_column
        column :name
        column :email
        column :current_sign_in_at
        column :sign_in_count
        column :created_at
        actions
    end

    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at

    # /admin/users/:device_id/unlink
    # unlink glasses with a given id
    member_action :unlink, :method => :post do
      glasses = Device.find(params[:id])
      user = glasses.current_owner
      glasses.unlink_from!(user: user, reason: 'ADMIN')

      redirect_to request.referer
    end

    # /admin/users/:token_id/revoke
    # revoke a token with a given id
    member_action :revoke, :method => :post do
      token = AuthToken.find(params[:id])
      token.revoke!(reason: 'ADMIN')

      redirect_to request.referer
    end

    # /admin/users/:user_id/reset_password
    # send a password reset email to a user
    member_action :reset_password, :method => :post do
      User.find(params[:id]).send_reset_password_instructions

      redirect_to request.referer
    end

  show do
    @all_glasses = user.devices
    @auth_tokens = user.active_auth_tokens
    @quiet_zones = user.quietzones

    # format methods to handle any empty values
    def format_text(text, empty="Unknown")
      text.blank? ? empty : text
    end

    def format_time(time, empty="Unknown")
      time.blank? ? empty : time.in_time_zone('Australia/Sydney').strftime('%e %b %Y %l:%M %p')
    end

    def format_link(link,  href="", empty="Unknown")
      link.blank? ? empty : content_tag(:a, link, href: href)
    end

    def format_bool(bool, yes="Yes", no="No")
      bool ? yes : no
    end

    def format_coords(latitude, longitude, empty="Unknown")
      latitude.blank? || longitude.blank? ? empty : content_tag(:a, "#{latitude.round(6)}, #{longitude.round(6)}", href: "http://maps.google.com/?q=#{latitude},#{longitude}")
    end

    def format_location(location, empty="Unknown")
      return empty if location.blank?

      # build a formatted address
      formatted_address = ""
      formatted_address << location["name"] + ", " if !location["name"].blank?
      formatted_address << location["housenumber"] + ", " if !location["housenumber"].blank?
      formatted_address << location["street"] + ", " if !location["street"].blank?
      formatted_address << location["state"] + ", " if !location["state"].blank?
      formatted_address << location["country"] if !location["country"].blank?
    end

    def reverse_geocode(latitude, longitude)
      return if latitude.blank? || longitude.blank?
      response = HTTParty.get("https://api.tzukuri.com/photon/reverse?lon=#{longitude}&lat=#{latitude}")
      return response.parsed_response["features"][0]["properties"]
    end

    div :class => 'container user-detail' do

      # user header
      div :class => "user-section" do
        h2 "User Details"
        div :class => 'row' do
          div :class => 'five columns' do
            dl do
              dt "NAME"
              dd format_text(user.name)
              dt "EMAIL"
              dd format_link(user.email, "mailto:#{user.email}")
              dt "REGISTERED"
              dd format_time(user.created_at)
            end
          end

          div :class => 'five columns' do
            dl do
              dt "LOCKED"
              dd format_bool(user.access_locked?, 'Locked', 'Unlocked')
              dt "LOCKED AT"
              dd format_time(user.locked_at, "N/A")
              dt "SIGNED IN"
              dd format_time(user.current_sign_in_at)
            end
          end

          div :class => 'two columns' do
            link_to "Reset Password","/admin/users/#{user.id}/reset_password", method: :post, data: {confirm: "Are you sure you want to send an email prompting this user to reset their password?"}
          end
        end
      end
      hr

      # glasses row
      div :class => "user-section" do
        h2 "Glasses"

        if @all_glasses.count == 0
          div :class => 'row empty' do
            h2 "This user has no Glasses"
          end
        end

        @all_glasses.each do |glasses|
          location = reverse_geocode(glasses.latitude, glasses.longitude)

          div :class => 'user-card glasses' do
            div :class => 'row card-head' do
              div :class => 'one columns' do
                image_tag("/images/frames/#{glasses.design.downcase}/#{glasses.design.downcase}_#{glasses.colour.downcase}_#{glasses.optical ? 'optical' : 'sun'}.jpg", style: 'width: 100%')
              end

              div :class => 'nine columns' do
                h3 "#{glasses.design}, #{glasses.colour}, #{glasses.optical ? 'Optical' : 'Sun'}"
              end

              div :class => "two columns card-title #{glasses.state}" do
                para glasses.state.upcase
              end
            end

            div :class => 'row card-body' do
              div :class => 'five columns' do
                dl do
                  dt "SERIAL"
                  dd format_link(glasses.serial, "/admin/devices/#{glasses.id}")
                  dt "PIN"
                  dd format_text(glasses.pin)
                  dt "STATE"
                  dd format_text(glasses.state)
                end
              end

              div :class => 'five columns' do
                dl do
                  dt "LOCATION"
                  dd format_location(location)
                  dt "COORD"
                  dd format_coords(glasses.latitude, glasses.longitude)
                  dt "COORD SET"
                  dd format_time(glasses.coords_set_time) + " (#{time_ago_in_words(glasses.coords_set_time)} ago)"
                end
              end

              div :class => 'two columns action-col' do
                link_to "Unlink Glasses","/admin/users/#{glasses.id}/unlink", method: :post, data: {confirm: "Are you sure you want to unlink these Glasses?"}
              end
            end
          end
        end
      end
      hr

      # phones section
      div :class => "user-section" do
        h2 "Phones"

        if @auth_tokens.count == 0
          div :class => 'row empty' do
            h2 "This user has no Phones"
          end
        end

        @auth_tokens.each do |token|
          div :class => 'user-card device' do
            div :class => 'row card-head' do
              div :class => 'ten columns' do
                h3 format_text(token.api_device.name, 'Unknown Device Name')
              end

              div :class => 'two columns card-title' do
                para "PHONE"
              end
            end

            div :class => 'row card-body' do
              div :class => 'five columns' do
                dl do
                  dt "DEVICE"
                  dd format_link("#{token.api_device.device_type}", "http://everymac.com/ultimate-mac-lookup/?search_keywords=#{token.api_device.device_type}")
                  dt "iOS"
                  dd format_text(token.api_device.os)
                  dt "AUTH TOKEN"
                  dd format_text(token.token)
                end
              end

              div :class => 'five columns' do
                dl do
                  dt "VERSION"
                  dd "--"
                  dt "CREATED"
                  dd format_time(token.api_device.created_at)
                  dt "DIAG TOKEN"
                  dd format_link(token.diagnostics_sync_token, "/admin/diagnostics/#{token.diagnostics_sync_token}")
                end
              end

              div :class => 'two columns action-col' do
                link_to "Revoke Tokens","/admin/users/#{token.id}/revoke", method: :post, data: {confirm: "Are you sure you want to revoke the Auth Token for this device?"}
              end
            end
          end
        end
      end
      hr

      # quiet zone section
      div :class => "user-section" do
        h2 "Quiet Zones"

        if @quiet_zones.count == 0
          div :class => 'row empty' do
            h2 "This user has no Quiet Zones"
          end
        end

        @quiet_zones.each do |zone|
          location = reverse_geocode(zone.latitude, zone.longitude)
          div :class => 'user-card quietzone' do
            div :class => 'row card-head' do
              div :class => 'ten columns' do
                h3 zone.name
              end

              div :class => 'two columns card-title' do
                para "QUIET ZONE"
              end
            end

            div :class => 'row card-body' do
              div :class => 'six columns' do
                dl do
                  dt "ALWAYS"
                  dd format_bool(zone.always_active)
                  dt "RADIUS"
                  dd format_text(zone.radius)
                  dt "START"
                  # dd format_time(zone.starttime)
                  dd zone.starttime
                end
              end

              div :class => 'six columns' do
                dl do
                  dt "LOCATION"
                  dd format_location(location)
                  dt "COORD"
                  dd format_coords(zone.latitude, zone.longitude)
                  dt "END"
                  # dd format_time(zone.endtime)
                  dd zone.endtime
                end
              end
            end
          end
        end
      end

    end
  end

end
