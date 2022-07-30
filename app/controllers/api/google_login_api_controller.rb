class Api::GoogleLoginApiController < ApplicationController
  skip_before_action :require_login
  protect_from_forgery except: :callback

  def callback
    binding.pry
    redirect_to dashboards_path, success: 'ログインしました'
  end
end
