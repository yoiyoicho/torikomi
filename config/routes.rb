Rails.application.routes.draw do
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
end
