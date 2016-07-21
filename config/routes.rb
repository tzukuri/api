require 'que/web'

Rails.application.routes.draw do
    # -----------------------------
    # devise routes
    # -----------------------------
    devise_for :admin_users, ActiveAdmin::Devise.config
    devise_for :users

    # devise for beta user with custom controllers for omniauth and registrations
    devise_for :beta_users, :controllers => {
        omniauth_callbacks: 'beta_users/omniauth_callbacks',
        registrations: 'beta_users/registrations'
    }

    # devise routes to replace the ones that you usually get from database_authenticatable
    devise_scope :beta_user do
        authenticate :beta_user do
            get     '/beta_users/latest_score'  => 'beta#latest_score'
        end

        post    '/beta_users/sign_in'   => 'devise/sessions#create',    :as => :beta_user_session
        get     '/beta_users/sign_in'   => 'devise/sessions#new',       :as => :new_beta_user_session
        delete  '/beta_users/sign_out'  => 'devise/sessions#destroy',   :as => :destroy_beta_user_session
        post    '/beta_users/sign_up'   => 'devise/registrations#new'
    end

    ActiveAdmin.routes(self)
    mount Que::Web => '/que'

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
    resources :beta_responses
    resources :beta_orders

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


    # beta routes
    get '/beta/forgot'          => 'beta#forgot',       :as => :beta_user_forgot
    post '/beta/retrieve'       => 'beta#retrieve',     :as => :beta_user_retrieve
    # redirect twitter on failed authentication
    get '/beta/redirect'        => 'beta#redirect'
    get '/beta/:token'          => 'beta#index',        :as => :beta_user
    get '/beta/invite/:token'   => 'beta#invite',       :as => :beta_user_invite
    get '/beta'                 => redirect('/')

    # beta user aggregations
    get '/beta/beta_users/count' => 'beta#count'
    get '/beta/beta_users/list'  => 'beta#list'
    get '/beta/beta_users/list_order' => 'beta#list_order'
    get '/beta/beta_users/graph'  => 'beta#graph'

    # diagnostics
    get '/diagnostics/:diag_token/:date/:file_name' => 'diagnostics#index'

    # mailer preview paths
    # get '/rails/mailers' => "rails/mailers#index"
    # get '/rails/mailers/*path' => "rails/mailers#preview"

    get '*page'                 => 'pages#index'

    # root 'pages#index', page: 'index'
    root 'beta#invite'
end
