class SettingsController < ApplicationController
  before_action :set_setting

  def show
  end

  def edit
    session[:previous_url] = request.referer
  end

  def update
    notification_time_before = @setting.notification_time
    if @setting.update(setting_params)
      if notification_time_before != @setting.notification_time
        current_user.schedules.to_be_sent.each do |schedule|
          destroy_service = Schedule::JobDestroyService.new(schedule)
          destroy_service.call

          set_service = Schedule::JobSetService.new(schedule)
          set_service.call
        end
      end
      redirect_to session[:previous_url] ||= dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :edit, status: :unprocessable_entity
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
