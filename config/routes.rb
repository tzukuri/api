Rails.application.routes.draw do
    resources :emails do
        collection do
            get :csv
        end
    end
    get '*page', to: 'pages#index'
    root 'pages#index', page: 'index'
end
