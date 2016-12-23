Rails.application.routes.draw do
  resources :payments
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  mount ActionCable.server => '/cable'

  require 'sidekiq/web'
  mount Sidekiq::Web => 'sidekiq'

  mount_griddler('/email/incoming')

  post '/tasks/dummy' => 'rooms#create_dummy'
  get '/tasks/from_sign_up' => 'rooms#create_room_from_sign_up', :as => 'task_from_sign_up'
  resources :rooms, shallow: true, path: 'tasks' do
    resources :messages

    member do
      post :mark_messages_seen
      get :accept
      get :deny_slack
      get :reject
      get :freelancers_list
      get :asign_freelancer
      get :remove_asigned_freelancer
    end
  end

  resources :slacks, only: [] do
    post :incoming, on: :collection
  end

  resources :freelancers, only: [] do
    collection do
      get :deny_slack
      post :accept_kriya_policy
    end
  end

  get 'task/p/:token', to: 'posts#public' , as: :public_post

  resources :photos
  resources :follows
  root to: "pages#index"
  get '/network' => 'pages#network', :as => 'network'
  get '/skills/search' => 'skills#search'

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
  resources :freelancer_rates
  resources :freelancers_rooms

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :users, only: [:index, :show], concerns: :followable


  devise_for :freelancers, controllers: {
    registrations: 'freelancers/registrations'
  }

  get "/auth/:provider/callback" => "omniauth_callbacks#create"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
