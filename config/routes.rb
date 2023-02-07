Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
    post :import, on: :collection
  end
end
