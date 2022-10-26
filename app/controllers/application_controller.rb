class ApplicationController < ActionController::Base
  add_flash_types :success, :error
  before_action :require_login

  private

  def not_authenticated
    redirect_to login_path, error: t('defaults.please_login_first')
  end

  def require_not_logged_in
    redirect_to dashboards_path, error: t('defaults.invalid_access') if logged_in?
  end
end
