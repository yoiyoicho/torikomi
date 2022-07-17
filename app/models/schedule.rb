class Schedule < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, length: { maximum: 65535 }
  validates :start_time, presence: true
  validates :end_time, presence: true
end
