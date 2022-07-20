class LineUsersController < ApplicationController
  before_action :set_hotp

  def index
    @otp = @hotp.at(current_user.id)
    @line_users = current_user.line_users
  end

  def update
  end

  def destroy
  end

  private

  def set_hotp
    @hotp = ROTP::HOTP.new(ENV['OTP_SECRET'])
  end 
end
