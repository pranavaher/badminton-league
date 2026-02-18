Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  resources :players
  resources :players do
    get :stats, on: :member
  end
  resources :matches do
    post :decide, on: :member
  end

  get "leaderboard", to: "home#leaderboard", as: :leaderboard
  get "statistics", to: "home#statistics", as: :statistics
  root "home#index"

  get "admin", to: "home#index", as: :admin_root
end
