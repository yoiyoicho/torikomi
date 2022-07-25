class LineUsersController < ApplicationController
  # before_action :set_hotp

  def index
    # @otp = @hotp.at(current_user.id)
    @line_users = current_user.line_users
    if current_user.link_token.present? && current_user.link_token_created_at > 1.week.ago.in_time_zone
      @login_url = root_url + current_user.link_token + '/login?user_id=' + current_user.id.to_s
    end
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

  # private

  # def set_hotp
  #   @hotp = ROTP::HOTP.new(ENV['OTP_SECRET'])
  # end 
end
