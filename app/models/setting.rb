class Setting < ApplicationRecord
  belongs_to :user

  validates :notification_time, presence: true, length: { minimum: 0, maximum: 120 }
  validates :message_option, presence: true
  validates :message_text, length: { maximum: 255 }

  enum message_option: { only_start_time: 0, start_time_and_title: 1, all: 2 }
end
