class GoogleCalendarToken < ApplicationRecord
  belongs_to :user

  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
end
