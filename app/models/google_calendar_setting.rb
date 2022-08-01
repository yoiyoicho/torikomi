class GoogleCalendarSetting < ApplicationRecord
  belongs_to :user

  validates :monday, presence: true
  validates :tuesday, presence: true
  validates :wednesday, presence: true
  validates :thrusday, presence: true
  validates :friday, presence: true
  validates :saturday, presence: true
  validates :sunday, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :end_time_cannot_be_earier_than_start_time

  def end_time_cannot_be_earier_than_start_time
    if end_time < start_time
        errors.add(:end_time, "は開始時刻より先の時刻にしてください")
    end
  end
end
