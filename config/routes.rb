Rails.application.routes.draw do
    resources :beta, param: :invite_code
    resources :beta_signups

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

    get '*page', to: 'pages#index'
    root 'pages#index', page: 'index'

end
