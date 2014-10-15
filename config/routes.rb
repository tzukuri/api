Rails.application.routes.draw do
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
    get '*page', to: 'pages#index'
    root 'pages#index', page: 'index'
end
