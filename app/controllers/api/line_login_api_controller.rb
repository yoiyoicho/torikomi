class Api::LineLoginApiController < ApplicationController
  require 'json'
  require 'typhoeus'

  skip_before_action :require_login

  USER = User.find(1) #あとで変更する
  STATE = '123abc' #あとで変更する
  #あとで、USER、STATEの組み合わせを一意にする

  def login
    session[:user_id] = params[:user_id]
    session[:state] = params[:link_token]

    authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
    response_type = 'code'
    client_id = ENV['LINE_LOGIN_CHANNEL_ID']
    redirect_uri = CGI.escape(api_callback_url)
    state = params[:id]
    scope = 'profile%20openid'
    
    login_url = "#{authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"
    redirect_to login_url, allow_other_host: true
  end

  def callback
    if params[:state] == session[:state]
      user = User.find(session[:user_id])
      line_user_params = get_line_user_params(params[:code])
      line_user = user.line_users.new(line_user_params)
      if line_user.save
        redirect_to line_users_path, success: 'トリコミのLINEユーザーに追加されました'
      else
        redirect_to line_users_path, error: 'エラーが起きました'
      end
    else
      redirect_to line_users_path, error: 'エラーが起きました'
    end
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
end
