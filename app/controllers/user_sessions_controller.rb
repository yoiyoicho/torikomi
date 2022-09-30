class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i(new create)

  def new
  end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_to dashboards_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, success: t('.success')
  end
end
