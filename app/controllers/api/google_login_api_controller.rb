class Api::GoogleLoginApiController < ApplicationController
  require "googleauth/id_tokens/errors"
  require "googleauth/id_tokens/verifier"

  skip_before_action :require_login
  protect_from_forgery except: :callback

  def callback
    # 以下のドキュメントをもとに実装
    # https://developers.google.com/identity/gsi/web/guides/display-button
    # https://developers.google.com/identity/gsi/web/reference/html-reference#id-token-handler-endpoint
    # https://github.com/googleapis/google-auth-library-ruby/blob/main/lib/googleauth/id_tokens.rb

    if params[:credential].present?
      payload = Google::Auth::IDTokens.verify_oidc(params[:credential], aud: ENV['GOOGLE_CLIENT_ID'])
      user = User.find_or_initialize_by(email: payload['email'], login_type: :google)

      puts payload
      puts payload['email']

      if user.save
        user.build_setting.save! if user.setting.blank?
        user.build_google_calendar_setting.save! if user.google_calendar_setting.blank?
        auto_login(user)
        redirect_to dashboards_path, success: 'Googleアカウントでログインしました'
      else
        redirect_to login_path, error: 'Googleアカウントでのログインに失敗しました'
      end
    
    else
      redirect_to login_path, error: 'Googleアカウントでのログインに失敗しました'
    end
  end
end
