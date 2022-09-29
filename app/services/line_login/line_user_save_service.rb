class LineLogin::LineUserSaveService
  require 'json'
  require 'typhoeus'

  def initialize(params, session)
    @user = User.find(session[:app_user_id])
    @code = params[:code]
  end
  
  def call
    line_user_params = get_line_user_params(@code)
    line_user = LineUser.find_or_initialize_by(line_user_id: line_user_params[:line_user_id])
    line_user.assign_attributes(line_user_params)
    if line_user.save && UserLineUserRelationship.find_or_create_by(user: @user, line_user: line_user)
      true
    else
      false
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

    # LINEユーザーのアクセストークンを発行する
    # https://developers.line.biz/ja/reference/line-login/#issue-access-token
    # ここではLINEユーザーのID、表示名、プロフィール画像のみ取得

    url = 'https://api.line.me/oauth2/v2.1/token'
    redirect_uri = api_line_login_callback_url

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