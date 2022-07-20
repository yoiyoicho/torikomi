class LineUser < ApplicationRecord
  belongs_to :user

  validates :line_user_id, presence: true, uniqueness: { scope: :user }
  validates :display_name, presence: true
  validates :status, presence: true

  enum status: { unapproved: 0, approved: 1 }
end
