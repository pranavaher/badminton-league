Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  root "home#index"

  get "admin", to: "home#index", as: :admin_root
end
