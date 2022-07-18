class ApplicationController < ActionController::Base
  add_flash_types :success, :error
  before_action :require_login

  private

  def not_authenticated
    redirect_to login_path, error: t('defaults.please_login_first')
  end
end
