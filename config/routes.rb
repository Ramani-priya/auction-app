# frozen_string_literal: true

require 'sidekiq/web'
Rails.application.routes.draw do
  # Devise routes
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register',
  }

  # Root path
  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Dashboard
  get 'dashboard', to: 'dashboard#index'

  # Auctions
  resources :auctions, only: %i[index show new create] do
    resources :bids, only: %i[new create]
    collection do
      get :manage_auctions
    end
    member do
      patch :publish
    end
  end
  resources :bids, only: [:index]
  mount Sidekiq::Web => '/sidekiq'
end
