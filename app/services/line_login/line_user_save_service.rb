class LineLogin::LineUserSaveService
  require 'json'
  require 'typhoeus'
  include Rails.application.routes.url_helpers

  def initialize(params, session, redirect_uri)
    @user = User.find(session[:app_user_id])
    @code = params[:code]
    @redirect_uri = redirect_uri
  end

  def call
    line_user_profile = get_line_user_profile(@code)
    line_user = LineUser.find_or_initialize_by(line_user_id: line_user_profile[:line_user_id])
    line_user.assign_attributes(line_user_profile)
    if line_user.save && UserLineUserRelationship.find_or_create_by(user: @user, line_user: line_user)
      true
    else
      false
    end
  end

  private

  def get_line_user_profile(code)

    # LINEユーザーのIDトークンを取得
    id_token = get_line_user_id_token(code)

    # IDトークンからユーザーのプロフィール情報（ID、表示名、プロフィール画像）を取得
    # https://developers.line.biz/ja/reference/line-login/#verify-id-token

    profile = {}

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
        profile.merge!({ line_user_id: JSON.parse(response.body)['sub'], display_name: JSON.parse(response.body)['name'], picture_url: JSON.parse(response.body)['picture']||=nil })
      end

    end

    profile

  end

  def get_line_user_id_token(code)

    # LINEユーザーのプロフィール情報取得に必要なIDトークンを発行する
    # https://developers.line.biz/ja/reference/line-login/#issue-access-token

    url = 'https://api.line.me/oauth2/v2.1/token'

    options = {
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: @redirect_uri,
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