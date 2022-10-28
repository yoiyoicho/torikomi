class Admin::UsersController < Admin::ApplicationController
  def index
    @resources = User.all
    render template: 'admin/layouts/index'
  end

  def show
    @resource = User.find(params[:id])
    render template: 'admin/layouts/show'
  end
end
