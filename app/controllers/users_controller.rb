class UsersController < ApplicationController
  require 'sidekiq/api'

  skip_before_action :require_login, only: %i(new create)

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if params[:id].to_i != current_user.id
      redirect_to dashboards_path, error: t('defaults.invalid_access')
    end
  end

  def destroy
    # Sidekiqに登録されているLINEメッセージの送信ジョブを削除する
    ss = Sidekiq::ScheduledSet.new
    current_user.schedules.each do |schedule|
      jobs = ss.select { |job| job.args[0]['job_id'] == schedule.job_id }
      jobs.each(&:delete)
    end
    current_user.destroy!
    redirect_to root_path, success: t('.success')
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
