class UsersController < ApplicationController
  skip_before_action :require_login, only: %i(new create)
  before_action :require_not_logged_in, only: %i(new create)

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
    current_user.schedules.each do |schedule|
      destroy_service = Schedule::JobDestroyService.new(schedule)
      destroy_service.call
    end
    current_user.destroy!
    redirect_to root_path, success: t('.success')
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
