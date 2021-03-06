Rails.application.routes.draw do
  root to: 'movies#index'
  resources :movies do
    post :vote
  end
  devise_for :users do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
