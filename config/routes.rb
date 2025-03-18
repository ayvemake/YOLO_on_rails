require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :analyses, only: [:index, :show, :new, :create, :destroy] do
    member do
      get :status
    end
  end
  
  namespace :api do
    namespace :v1 do
      resources :analyses, only: [:create, :show]
    end
  end

  # Ajouter ces lignes pour les détections de défauts
  resources :defect_detections, only: [:new, :create, :show]

  root 'dashboard#index'
  

  # Route pour les WebSockets
  mount ActionCable.server => '/cable'

  # Mount Sidekiq web UI
  # You might want to add authentication here
  mount Sidekiq::Web => '/sidekiq'

  get 'documentation', to: 'documentation#index'
end
