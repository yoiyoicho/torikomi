class SettingsController < ApplicationController
  before_action :set_setting

  def index
  end

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to settings_path, success: t('success')
    else
      flash.now[:error] = t('.fail')
      render :edit
    end
  end

  private

  def set_setting
    @setting = current_user.setting
  end
end
