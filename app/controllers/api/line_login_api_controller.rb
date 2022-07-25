class Api::LineLoginApiController < ApplicationController
  require 'json'
  require 'typhoeus'

  skip_before_action :require_login

  USER = User.find(1) #あとで変更する
  STATE = '123abc' #あとで変更する
  #あとで、USER、STATEの組み合わせを一意にする

  def login
    authorization_url = 'https://access.line.me/oauth2/v2.1/authorize'
    response_type = 'code'
    client_id = ENV['LINE_LOGIN_CHANNEL_ID']
    redirect_uri = 'https%3A%2F%2F0d87-240b-251-9460-9600-3c19-9301-dd7b-1b81.jp.ngrok.io%2Fapi%2Fcallback'
    state = STATE
    scope = 'profile%20openid'
    
    request_url = "#{authorization_url}?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{STATE}&scope=#{scope}"
    redirect_to request_url, allow_other_host: true
  end

  def callback
    if params[:state] == STATE
      line_user_params = get_line_user_params(params[:code])
      line_user = USER.line_users.new(line_user_params)
      if line_user.save
        redirect_to line_users_path, success: 'ログインできました'
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
    redirect_uri = 'https://0d87-240b-251-9460-9600-3c19-9301-dd7b-1b81.jp.ngrok.io/api/callback'

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
