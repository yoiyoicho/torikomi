class LineUsersController < ApplicationController
  before_action :set_hotp

  def index
    @otp = @hotp.at(current_user.id)
    @line_users = current_user.line_users
  end

  def update
    @line_user = current_user.line_users.find(params[:id])
    @line_user.update!(status: :approved)
    redirect_to line_users_path, success: t('.success')
  end

  def destroy
    @line_user = current_user.line_users.find(params[:id])
    @line_user.destroy!
    redirect_to line_users_path, success: t('.success')
  end

  private

  def set_hotp
    @hotp = ROTP::HOTP.new(ENV['OTP_SECRET'])
  end 
end
