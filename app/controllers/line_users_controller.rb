class LineUsersController < ApplicationController

  def index
    @line_users = current_user.line_users
    @login_url = create_login_url(current_user)
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
      render :index
    end
  end

  def destroy
    @line_user = current_user.line_users.find(params[:id])
    @line_user.destroy!
    redirect_to line_users_path, success: t('.success')
  end

  private

  def create_login_url(user)
    token = SecureRandom.urlsafe_base64
    user.link_tokens.create!(token: token)
    login_url = root_url + 'api/' + token + '/login'
    login_url
  end

end
