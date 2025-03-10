Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'dashboard#index'

  resources :analyses, only: [:index, :show, :new, :create] do
    member do
      get :status
    end
  end
  resources :components
  
  namespace :api do
    namespace :v1 do
      resources :analyses, only: [:create, :show]
    end
  end
  
  # Route pour les WebSockets
  mount ActionCable.server => '/cable'
end
