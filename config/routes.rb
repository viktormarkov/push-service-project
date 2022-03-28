Rails.application.routes.draw do
  devise_for :users
  root to: 'web/push_messages#index'

  scope module: :web do
    resources :users
    resources :push_messages, only: [:index, :new, :create, :show]
  end

  namespace :api, constraints: { format: :json }, defaults: { format: :json } do
    resources :device_tokens, only: [:create]
  end
end
