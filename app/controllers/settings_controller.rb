class SettingsController < ApplicationController
  before_action :set_setting

  def show
  end

  def edit
    session[:previous_url] = request.referer
  end

  def update
    if @setting.update(setting_params)
      redirect_to session[:previous_url] ||= dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit
    end
  end

  private

  def set_setting
    @setting = current_user.setting
  end

  def setting_params
    params.require(:setting).permit(:notification_time, :message_option, :message_text)
  end
end
