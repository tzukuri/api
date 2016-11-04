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

  show do
    @all_glasses = user.devices
    @auth_tokens = user.auth_tokens
    @quiet_zones = user.quietzones

    div :class => 'container user-detail' do
      # glasses row
      h2 "Glasses"

      if @quiet_zones.count == 0
        div :class => 'row empty' do
          h2 "This user has no Glasses"
        end
      end

      @all_glasses.each do |glasses|
        # reverse geocode this glasses coordinates
        if glasses.latitude && glasses.longitude
          response = HTTParty.get("https://api.tzukuri.com/photon/reverse?lon=#{glasses.longitude}&lat=#{glasses.latitude}")
          location =  response.parsed_response["features"][0]["properties"]
        end
        div :class => 'user-card glasses' do
          div :class => 'row card-head' do
            div :class => 'one columns' do
              img src: "/images/frames/#{glasses.design}/#{glasses.design}_#{glasses.colour}_#{glasses.optical ? 'optical' : 'sun'}.jpg", style: 'width: 100%'
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
                dd glasses.serial
                dt "PIN"
                dd glasses.pin
                dt "STATE"
                dd glasses.state.titleize
              end
            end

            div :class => 'five columns' do
              dl do
                dt "LOCATION"
                dd location ? "#{location["name"]}, #{location["city"]}, #{location["country"]}" : "Unknown"
                dt "COORD"
                if location
                  dd a "#{glasses.latitude}, #{glasses.longitude}", href: "http://maps.google.com/?q=#{glasses.latitude},#{glasses.longitude}"
                else
                  dd "Unknown"
                end
                dt "TIME"
                dd location ? glasses.coords_set_time.strftime('%e %b %Y %l:%M %p') : "Unknown"
              end
            end

            div :class => 'two columns' do
              a "Unlink"
            end
          end
        end
      end

      # phones section
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
              h3 token.api_device.name
            end

            div :class => 'two columns card-title' do
              para "PHONE"
            end
          end

          div :class => 'row card-body' do
            div :class => 'five columns' do
              dl do
                dt "DEVICE"
                dd  a "#{token.api_device.device_type}"
                dt "iOS"
                dd token.api_device.os
              end
            end

            div :class => 'five columns' do
              dl do
                dt "APP"
                dd "1.0b19"
                dt "TIME"
                dd "#{token.api_device.created_at.in_time_zone('Australia/Sydney').strftime('%e %b %Y %l:%M %p')}"
              end
            end

            div :class => 'two columns' do
              a "Unlink"
            end
          end
        end
      end

      # quiet zone section
      h2 "Quiet Zones"

      if @quiet_zones.count == 0
        div :class => 'row empty' do
          h2 "This user has no Quiet Zones"
        end
      end

      @quiet_zones.each do |zone|
        response = HTTParty.get("https://api.tzukuri.com/photon/reverse?lon=#{zone.longitude}&lat=#{zone.latitude}")
        location =  response.parsed_response["features"][0]["properties"]
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
                dd zone.always_active ? 'Yes' : 'No'
                dt "RADIUS"
                dd "#{zone.radius} metres"
                dt "START"
                dd zone.starttime ? zone.starttime.in_time_zone('Australia/Sydney').strftime('%e %b %Y %l:%M %p') : 'N/A'
              end
            end

            div :class => 'six columns' do
              dl do
                dt "LOCATION"
                dd location ? "#{location["name"]}, #{location["city"]}, #{location["country"]}" : "Unknown"
                dt "COORD"
                dd a "#{zone.latitude}, #{zone.longitude}", href: "http://maps.google.com/?q=#{zone.latitude},#{zone.longitude}"
                dt "END"
                dd zone.endtime ? zone.endtime.in_time_zone('Australia/Sydney').strftime('%e %b %Y %l:%M %p') : 'N/A'
              end
            end
          end
        end
      end
    end
  end

end
