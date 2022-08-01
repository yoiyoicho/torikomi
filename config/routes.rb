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

  # Googleログイン
  post '/api/google_login/callback', to: 'api/google_login_api#callback'

  # ダッシュボード
  get '/dashboards', to: 'dashboards#index'

  # スケジュール
  resources :schedules, only: %i(index new create edit update destroy)

  # Googleカレンダー
  get 'api/google_calendar/authorize', to: 'api/google_calendar_api#authorize', as: 'api_google_calendar_authorize'
  get 'api/google_calendar/callback', to: 'api/google_calendar_api#callback'
  get 'api/google_calendar/update', to: 'api/google_calendar_api#update'
  resources :google_calendar_tokens, only: :destroy

  # LINEユーザー
  resources :line_users, only: %i(index update destroy)
  # post '/api/callback', to: 'api/line_messaging_api#callback'
  get '/api/line_login/callback', to: 'api/line_login_api#callback'
  get '/api/line_login/:link_token/login', to: 'api/line_login_api#login', as: 'api_login'

  # 通知メッセージ設定
  resource :setting, only: %i(show edit update)

  # Googleカレンダー連携設定
  resource :google_calendar_setting, only: %i(show edit update)
end
