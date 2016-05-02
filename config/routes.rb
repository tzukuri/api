Rails.application.routes.draw do
  resources :beta_signups

    resources :beta_reservations

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
