Rails.application.routes.draw do
    resources :emails
    get '*page', to: 'pages#index'
    root 'pages#index', page: 'index'
end
