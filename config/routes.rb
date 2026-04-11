Rails.application.routes.draw do
  resources :tickets do
    resources :comments, only: [:create]
  end
  resources :ticket_statuses
  resources :ticket_types
  resources :blocks
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  namespace :admin do
    resources :users
    resources :user_units, only: [:index, :create, :destroy]
  end

  # Defines the root path route ("/")
  root "blocks#index"
end
