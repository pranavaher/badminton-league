Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  resources :players
  resources :matches do
    post :decide, on: :member
  end

  get "leaderboard", to: "home#leaderboard", as: :leaderboard
  root "home#index"

  get "admin", to: "home#index", as: :admin_root
end
