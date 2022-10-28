class Admin::LineUsersController < Admin::ApplicationController
  def index
    @line_users = LineUser.all
  end
end
