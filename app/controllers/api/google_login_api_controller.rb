class Api::GoogleLoginApiController < ApplicationController
  require "googleauth/id_tokens/errors"
  require "googleauth/id_tokens/verifier"

  skip_before_action :require_login
  protect_from_forgery except: :callback

  def callback
    payload = Google::Auth::IDTokens.verify_oidc(params[:credential], aud: ENV['GOOGLE_CLIENT_ID'])
    # email = payload['email']
    # name = payload['name']
    redirect_to dashboards_path, success: 'ログインしました'
  end
end
