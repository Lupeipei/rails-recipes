Rails.application.routes.draw do

  devise_for :users

  resources :events


  get "/faq" => "pages#faq"

  namespace :admin do
    root "events#index"
    resources :events
  end

  root "events#index"

end
