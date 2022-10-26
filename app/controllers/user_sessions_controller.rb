class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i(new create)
  before_action :require_not_logged_in, only: %i(new create)

  def new
    @user = User.new
  end

  def create
    @user = login(user_params[:email], user_params[:password])

    if @user
      redirect_to dashboards_path, success: t('.success')
    else
      @user = User.new(user_params)
      flash.now[:error] = t('.fail')
      @error_message = t('user_sessions.create.error_message')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, success: t('.success')
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
