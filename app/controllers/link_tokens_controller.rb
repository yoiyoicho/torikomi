class LinkTokensController < ApplicationController
  require 'securerandom'

  def create
    if current_user.link_token.present? && current_user.link_token_created_at > 1.week.ago.in_time_zone
      # 有効なlink_tokenがあるとき
      redirect_to line_users_path
    else
      link_token = SecureRandom.urlsafe_base64
      if current_user.update(link_token: link_token, link_token_created_at: Time.zone.now)
        redirect_to line_users_path
      else
        redirect_to line_users_path, error: 'エラーが発生しました'
      end
    end
  end
end
