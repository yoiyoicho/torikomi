class Api::LineLoginApiController < ApplicationController
  require 'json'
  require 'typhoeus'
  require 'securerandom'

  skip_before_action :require_login, only: %i(login callback)

  # sessionを有効にするためにCSRF対策を外す（あとで検討）
  protect_from_forgery except: %i(login callback)

  def login

    user = User.find_by(id: params[:app_user_id].to_i)
    link_token = params[:link_token]

    # アプリユーザーが存在し、link_tokenが正しく、selfパラメーターが正しいフォーマットの場合にLINEログイン処理へ移る
    # selfパラメーターは、アプリユーザーが自分のLINEアカウントを登録しようとしているときにture
    # アプリユーザーが自分でないLINEユーザーに登録してもらおうとしているときにfalse

    if user && LinkToken.valid?(user.id, link_token) && ( params[:self] == 'true' || params[:self] == 'false' )

      session[:app_user_id] = user.id
      session[:self] = params[:self]
      session[:state] = SecureRandom.urlsafe_base64 #クロスサイトリクエストフォージェリ防止用のトークン

      # LINEユーザーに認証と認可を要求する
      # https://developers.line.biz/ja/docs/line-login/integrate-line-login/#making-an-authorization-request

      authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
      response_type = 'code'
      client_id = ENV['LINE_LOGIN_CHANNEL_ID']
      redirect_uri = CGI.escape(api_line_login_callback)
      state = session[:state]
      scope = 'profile%20openid'
    
      login_url = "#{authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

      redirect_to login_url, allow_other_host: true

    else

      redirect_to root_path, error: 'LINEユーザーのログインURLが正しくありません'

    end
  end

  def callback

    if params[:state] == session[:state]

      user = User.find(session[:app_user_id])
      line_user_params = get_line_user_params(params[:code])
      line_user = LineUser.find_or_initialize_by(line_user_id: line_user_params[:line_user_id].to_i)
      line_user.assign_attributes(line_user_params)

      if line_user.save && UserLineUserRelationship.find_or_create_by(user: user, line_user: line_user)
        reset_session_before_redirect(session[:self])
        flash[:success] = 'トリコミのLINEユーザーに追加されました'
      else # line_userが不正か、relationが不正だったとき
        reset_session_before_redirect(session[:self])
        flash[:error] = 'エラーが起きました'
      end

    else # LINEログインの通信に失敗しているとき
      reset_session_before_redirect(session[:self])
      flash[:error] = 'エラーが起きました'
    end

    redirect_to root_path

  end

  private

  def get_line_user_params(code)

    line_user_params = {}
    id_token = get_line_user_id_token(code)

    if id_token.present?

      url = 'https://api.line.me/oauth2/v2.1/verify'
      options = {
        body: {
          id_token: id_token,
          client_id: ENV['LINE_LOGIN_CHANNEL_ID']
        }
      }

      response = Typhoeus::Request.post(url, options)

      if response.code == 200
        line_user_params.merge!({ line_user_id: JSON.parse(response.body)['sub'], display_name: JSON.parse(response.body)['name'], picture_url: JSON.parse(response.body)['picture']||=nil })
      end

    end

    line_user_params

  end

  def get_line_user_id_token(code)

    # LINEユーザーのアクセストークンを発行する
    # https://developers.line.biz/ja/reference/line-login/#issue-access-token
    # ここではLINEユーザーのID、表示名、プロフィール画像のみ取得

    url = 'https://api.line.me/oauth2/v2.1/token'
    redirect_uri = api_callback_url

    options = {
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri,
        client_id: ENV['LINE_LOGIN_CHANNEL_ID'],
        client_secret: ENV['LINE_LOGIN_CHANNEL_SECRET']
      }
    }
    response = Typhoeus::Request.post(url, options)

    if response.code == 200 && JSON.parse(response.body)['id_token'].present?
      JSON.parse(response.body)['id_token']
    else
      nil
    end
  end

  def reset_session_before_redirect(self_flag)

    if self_flag == 'true'
      # アプリユーザーが自分のLINEアカウントを登録しようとしているときは
      # LINEログイン後のsessionをログイン状態にしておく
      session[:state] = nil
      session[:app_user_id] = nil
      session[:self] = nil

    else
      # アプリユーザーが自分でないLINEユーザーに登録してもらおうとしているときは
      # LINEログイン後のsessionをログアウト状態にしておく
      reset_session
    end

  end

end
