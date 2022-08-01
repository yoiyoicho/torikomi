class GoogleCalendarSetting < ApplicationRecord
  belongs_to :user

  validates :monday, inclusion: {in: [true, false]}
  validates :tuesday, inclusion: {in: [true, false]}
  validates :wednesday, inclusion: {in: [true, false]}
  validates :thursday, inclusion: {in: [true, false]}
  validates :friday, inclusion: {in: [true, false]}
  validates :saturday, inclusion: {in: [true, false]}
  validates :sunday, inclusion: {in: [true, false]}
  validates :start_time_hour, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :start_time_min, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
  validates :end_time_hour, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :end_time_min, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }

  validate :end_time_cannot_be_earier_than_start_time

  def end_time_cannot_be_earier_than_start_time
    if (end_time_hour * 60 + end_time_min) < (start_time_hour * 60 + start_time_min)
      errors.add(:end_time, "は開始時刻より先の時刻にしてください")
    end
  end
end
