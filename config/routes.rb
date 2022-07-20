Rails.application.routes.draw do
  get 'line_users/index'
  get 'line_users/new'
  get 'line_users/create'
  get 'line_users/destroy'
  # トップページ
  root 'static_pages#top'

  # 静的ページ
  get '/terms', to: 'static_pages#terms'
  get '/privacy_policy', to: 'static_pages#privacy_policy'
  get '/contact', to: 'static_pages#contact'
  get '/faq', to: 'static_pages#faq'

  # ユーザー登録・ログイン・ログアウト
  resources :users, only: %i(create)
  get '/signup', to: 'users#new'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  # ダッシュボード
  get '/dashboards', to: 'dashboards#index'

  # スケジュール
  resources :schedules, only: %i(index new create edit update destroy)

  # LINEユーザー
  resources :line_users, only: %i(index update destroy)
  post '/callback', to: 'line_messaging_api#callback'
end
