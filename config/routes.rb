Rails.application.routes.draw do
    devise_for :admin_users, ActiveAdmin::Devise.config
    devise_for :users
    ActiveAdmin.routes(self)

    namespace :api do
        namespace :v0 do
            namespace :app_params do
                get '', action: 'show'
            end

            namespace :diagnostics do
                post ':diagnostic_sync_token/:device_id/:date/:file_name', action: 'create'
            end

            namespace :api_devices do
                put ':id', action: 'update'
            end

            namespace :users do
                post '', action: 'create'
                get 'current', action: 'show'
                put 'current', action: 'update'

                # returns all the quietzones for the current user
                get 'current_quietzones', action: 'get_quietzones'
            end

            namespace :auth_tokens do
                post '', action: 'create'
                delete '', action: 'delete'
            end

            namespace :devices do
                get '', action: 'index'
                get ':id', action: 'show'
                post ':id/link', action: 'link'
                post ':id/unlink', action: 'unlink'
                post ':id/location', action: 'location'
                post ':id/connected', action: 'connected'
                post ':id/disconnected', action: 'disconnected'
            end

            namespace :quietzones do
                # POST /api/v0/quietzones creates a new quiet zone for current user
                post 'new', action: 'create'

                # PUT /api/v0/quietzones/<id> updates the quietzone with the given id
                put 'update/:id', action: 'update'

                # DELETE /api/v0/quietzones/<id> deletes the quiet zone with the given id
                delete 'delete/:id', action: 'delete'
            end
        end
    end

    #root to: '/login'
end
