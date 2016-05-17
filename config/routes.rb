Rails.application.routes.draw do
    # -----------------------------
    # devise routes
    # -----------------------------
    devise_for :admin_users, ActiveAdmin::Devise.config
    devise_for :users

    devise_for :beta_users, :controllers => {
        omniauth_callbacks: 'beta_users/omniauth_callbacks',
        registrations: 'beta_users/registrations'
    }

    devise_scope :beta_user do
        post    '/beta_users/sign_in'   => 'devise/sessions#create'
        delete  '/beta_users/sign_out'  => 'devise/sessions#destroy'
        post    '/beta_users/sign_up'   => 'devise/registrations#new'
    end

    ActiveAdmin.routes(self)

    # -----------------------------
    # api namespace routes
    # -----------------------------
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

            resources :quietzones do
              resources :rooms do
                resources :recordings
              end
            end

        end
    end

    # -----------------------------
    # other web routes
    # -----------------------------
    # resources :beta_reservations
    # resources :beta, param: :invite_code
    # resources :beta_signups

    resources :betareservations do
      collection do
        get :csv
      end
    end

    resources :purchases do
        collection do
            get :csv
        end
    end

    resources :emails do
        collection do
            get :csv
        end
    end

    resources :rsvps do
      collection do
        get :csv
      end
    end

    # beta index and invite routes
    get '/beta/:token' => 'beta#index'
    get '/beta/invite/:token' => 'beta#invite'

    get '/dashboard', to: 'dashboard#index'
    get '*page', to: 'pages#index'
    root 'pages#index', page: 'index'
end
