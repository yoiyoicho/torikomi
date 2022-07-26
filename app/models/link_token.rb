class LinkToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true, uniqueness: true

  def not_expired?
    created_at > 1.days.ago.in_time_zone
  end
end
