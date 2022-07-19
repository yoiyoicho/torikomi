class LineUser < ApplicationRecord
  belongs_to :user

  validates :line_user_id, presence: true
  validates :display_name, presence: true
end
