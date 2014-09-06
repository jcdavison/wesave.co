Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  get '/events', to: 'budget_events#index', as: 'events'
  post '/events', to: 'budget_events#create', as: 'create_event'
  get '/home', to: 'home#index'
  get '/begin', to: 'institutions#begin'
  get '/step', to: 'institutions#step'
  post '/authorize', to: 'institutions#authorize'
  post '/mfa', to: 'institutions#mfa'
end
