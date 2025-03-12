require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :analyses, only: [:index, :show, :new, :create] do
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

  # Monter l'interface Web de Sidekiq avec authentification en production
  if Rails.env.production?
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  else
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'documentation', to: 'documentation#index'
end
