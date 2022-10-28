require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # 管理画面
  namespace :admin do
    root 'users#index'
    resources :users, only: %i(index)
    resources :schedules, only: %i(index)
    resources :line_users, only: %i(index)
  end
  # トップページ
  root 'static_pages#top'

  # 静的ページ
  get '/terms', to: 'static_pages#terms'
  get '/privacy_policy', to: 'static_pages#privacy_policy'
  get '/faq', to: 'static_pages#faq'
  get '/guide', to: 'static_pages#guide'
  get '/line', to: 'static_pages#line'

  # ユーザー登録・ログイン・ログアウト・設定
  resources :users, only: %i(destroy show)
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  # パスワードリセット
  resources :password_resets, only: %i(new create edit update)

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
  resources :line_users, only: %i(index destroy)
  get '/api/line_login/callback', to: 'api/line_login_api#callback'
  get '/api/line_login/:link_token/login', to: 'api/line_login_api#login', as: 'api_login'

  # 通知メッセージ設定
  resource :setting, only: %i(show edit update)

  # Googleカレンダー連携設定
  # resource :google_calendar_setting, only: %i(show edit update)
  resource :google_calendar_setting, only: :show

  # お問い合わせ
  resources :inquiries, only: %i(new create)

  # sidekiq管理画面
  Sidekiq::Web.use(Rack::Auth::Basic) do |user_id, password|
    [user_id, password] == [ENV['SIDEKIQ_ADMIN_USER_ID'], ENV['SIDEKIQ_ADMIN_PASSWORD']]
  end
  mount Sidekiq::Web, at: '/sidekiq'
end
