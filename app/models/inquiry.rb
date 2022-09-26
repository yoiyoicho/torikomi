class Inquiry < ApplicationRecord
  validates :body, presence: true, length: { maximum: 65535 }
  validates :email, presence: true
end
