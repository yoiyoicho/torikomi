Rails.application.routes.draw do
  root 'static_pages#top'

  get '/terms', to: 'static_pages#terms'
  get '/privacy_policy', to: 'static_pages#privacy_policy'
  get '/contact', to: 'static_pages#contact'

  resources :users, only: %i(create)
  get '/signup', to: 'users#new'
end
