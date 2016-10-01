Rails.application.routes.draw do
  resources :payments
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  require 'sidekiq/web'
  mount   Sidekiq::Web => 'sidekiq'

  post '/tasks/dummy' => 'rooms#create_dummy'
  get '/tasks/from_sign_up' => 'rooms#create_room_from_sign_up', :as => 'task_from_sign_up'
  resources :rooms, shallow: true, path: 'tasks' do
    resources :messages
  end
  resources :photos
  resources :follows
  root to: "pages#index"

  concern :likable do
    post :like, on: :member
  end

  concern :followable do
    post :follow, on: :member
  end

  resources :posts, shallow: true, concerns: :likable do
    resources :comments, only: [:create, :destroy, :update, :edit], shallow: true, concerns: :likable
  end

  resources :goomps, shallow: true do
    post :join, on: :member

    resources :reviews
    resources :posts
    resources :subtopics
  end

  resources :scrapes, only: [:create]
  resources :likes
  resources :memberships

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: 'users/registrations'
  }
  resources :users, only: [:index, :show], concerns: :followable
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
