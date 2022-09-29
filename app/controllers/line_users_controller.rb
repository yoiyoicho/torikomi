class LineUsersController < ApplicationController

  def index
    @line_users = current_user.line_users
    @login_url = LinkToken.create_line_login_url(root_url, current_user)
  end

  def update
    @line_user = current_user.line_users.find(params[:id])
    if params[:notification] == 'on'
      @line_user.assign_attributes(status: :notification_on)
    else
      @line_user.assign_attributes(status: :notification_off)
    end
    if @line_user.save
      redirect_to line_users_path, success: t('.success')
    else
      flash.now[:error] = t('.fail')
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @line_user = current_user.line_users.find(params[:id])
    @line_user.destroy!
    redirect_to line_users_path, success: t('.success')
  end
end
