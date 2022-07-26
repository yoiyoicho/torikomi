class LineUser < ApplicationRecord
  belongs_to :user

  validates :line_user_id, presence: true, uniqueness: { scope: :user }
  validates :display_name, presence: true
  validates :status, presence: true

  enum status: { notification_on: 0, notification_off: 1 }
end
