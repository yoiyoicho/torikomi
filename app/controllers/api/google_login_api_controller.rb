class Api::GoogleLoginApiController < ApplicationController
  # 以下のドキュメントをもとに実装
  # https://developers.google.com/identity/gsi/web/guides/display-button
  # https://developers.google.com/identity/gsi/web/reference/html-reference#id-token-handler-endpoint
  # https://github.com/googleapis/google-auth-library-ruby/blob/main/lib/googleauth/id_tokens.rb

  require "googleauth/id_tokens/errors"
  require "googleauth/id_tokens/verifier"

  skip_before_action :require_login

  # WebアプリとLINEプラットフォーム間でのCSRF対策は自前で行うため
  # RailsデフォルトのCSRF対策メソッドは無効化する
  protect_from_forgery except: :callback
  before_action :verify_g_csrf_token, only: :callback

  def callback
    if params[:credential].present?
      payload = Google::Auth::IDTokens.verify_oidc(params[:credential], aud: ENV['GOOGLE_CLIENT_ID'])
      user = User.find_or_initialize_by(email: payload['email'], login_type: :google)

      if user.save
        auto_login(user)
        redirect_to dashboards_path, success: t('.success')
      else
        redirect_to login_path, error: t('.fail')
      end

    else
      redirect_to login_path, error: t('.fail')
    end
  end

  private

  def verify_g_csrf_token
    if cookies["g_csrf_token"].blank? || params[:g_csrf_token].blank? || cookies["g_csrf_token"] != params[:g_csrf_token]
      redirect_to login_path, error: t('.fail')
    end
  end
end
