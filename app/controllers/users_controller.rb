class UsersController < ApplicationController
  skip_before_action :require_login, only: %i(new create)

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.build_setting.save!
      @user.build_google_calendar_setting.save!
      auto_login(@user)
      redirect_to dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
