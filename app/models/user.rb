class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :schedules, dependent: :destroy
  has_many :line_users, dependent: :destroy
  has_one :setting, dependent: :destroy

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, uniqueness: true, presence: true
  validates :link_token, uniqueness: true
end
