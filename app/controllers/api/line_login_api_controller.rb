class Api::LineLoginApiController < ApplicationController
  # 以下のドキュメントをもとに実装
  # https://developers.line.biz/ja/docs/line-login/integrate-line-login/#making-an-authorization-request
  # 関連する処理は、app/services/line_login/以下を参照のこと

  require 'securerandom'

  skip_before_action :require_login

  # WebアプリとLINEプラットフォーム間でのCSRF対策は自前で行うため
  # RailsデフォルトのCSRF対策メソッドは無効化する
  protect_from_forgery except: %i(login callback)

  def login
    # ログインURLのバリデーションを行う
    validate_service = LineLogin::LoginUrlValidateService.new(params)

    if validate_service.call

      # アプリユーザーとLINEユーザーの紐付けに必要な情報をsesssionに保存する
      session[:app_user_id] = params[:app_user_id]
      session[:self] = params[:self]

      #クロスサイトリクエストフォージェリ防止用のトークンをsessionに保存する
      session[:state] = SecureRandom.urlsafe_base64

      # LINEユーザーに認証と認可を要求する
      authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
      response_type = 'code'
      client_id = ENV['LINE_LOGIN_CHANNEL_ID']
      redirect_uri = CGI.escape(api_line_login_callback_url)
      state = session[:state]
      scope = 'profile%20openid'
    
      login_url = "#{authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

      redirect_to login_url, allow_other_host: true

    else
      redirect_to root_path, error: t('.fail')
    end
  end

  def callback
    # クロスサイトリクエストフォージェリ防止用のトークンを検証する
    if params[:state] == session[:state]

      # 返却されたparamsとsessionからLINEユーザーをfind or initializeし、
      # アプリユーザーと紐づけて保存する
      save_service = LineLogin::LineUserSaveService.new(params, session)

      if save_service.call #LINEユーザーが保存できたとき
        flash[:success] = t('.success')

      else # LINEユーザーが保存できなかったとき
        flash[:error] = t('.fail')
      end

    else # LINEログインの通信に失敗しているとき
      flash[:error] = t('.fail')
    end

    # アプリユーザー以外によるアクセスの場合、アプリからログアウト状態にする
    reset_session if session[:self] == 'false'
    redirect_to root_path
  end
end
