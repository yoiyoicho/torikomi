class Admin::ApplicationController < ApplicationController
  layout 'admin/layouts/application'
  before_action :check_admin

  private

  def check_admin
    redirect_to root_path, error: t('defaults.invalid_access') unless current_user.admin?
  end
end
