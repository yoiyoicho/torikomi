class Schedule < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, length: { maximum: 65535 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true
  validates :resource_type, presence: true
  validates :i_cal_uid, presence: true, if: :google?

  validate :start_time_cannot_be_in_the_past
  validate :end_time_cannot_be_earier_than_start_time

  enum status: { to_be_sent: 0, draft: 1, sent: 2 }
  enum resource_type: { default: 0, google: 1 }

  def start_time_cannot_be_in_the_past
    if to_be_sent? || draft?
      if start_time.present? && start_time < Time.zone.now
        errors.add(:start_time, "は現在より先の日時にしてください")
      end
    end
  end

  def end_time_cannot_be_earier_than_start_time
    if start_time.present? && end_time.present? && end_time < start_time
      errors.add(:end_time, "は開始日時より先の日時にしてください")
    end
  end
end
