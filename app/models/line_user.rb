class LineUser < ApplicationRecord
  has_many :user_line_user_relationships, dependent: :destroy
  has_many :users, through: :user_line_user_relationships

  validates :line_user_id, presence: true, uniqueness: { scope: :user }
  validates :display_name, presence: true
  validates :status, presence: true

  enum status: { notification_on: 0, notification_off: 1 }
end
