class GoogleCalendarToken < ApplicationRecord
  belongs_to :user

  validates :refresh_token, presence: true
  validates :google_calendar_id, presence: true
end
