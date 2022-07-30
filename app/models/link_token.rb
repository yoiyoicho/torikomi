class LinkToken < ApplicationRecord
  belongs_to :user
  validates :token_digest, presence: true

  def self.create_line_login_url(root_url, user)
    token = SecureRandom.urlsafe_base64
    user.link_tokens.create!(token_digest: Digest::MD5.hexdigest(token))
    line_login_url = root_url + 'api/line_login/' + token + "/login?app_user_id=#{user.id.to_s}"
    line_login_url
  end

  def self.valid?(user_id, token)
    link_token = LinkToken.find_by(user_id: user_id, token_digest: Digest::MD5.hexdigest(token))
    if link_token.present? && link_token.created_at > 1.days.ago.in_time_zone
      true
    else
      false
    end
  end
end
