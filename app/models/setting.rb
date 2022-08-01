class Setting < ApplicationRecord
  belongs_to :user

  validates :notification_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }
  validates :message_option, presence: true
  validates :message_text, length: { maximum: 255 }

  enum message_option: { only_time: 0, time_and_title: 1, time_and_title_and_body: 2 }
end
