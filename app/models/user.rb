class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :schedules, dependent: :destroy
  has_many :user_line_user_relationships, dependent: :destroy
  has_many :line_users, through: :user_line_user_relationships
  has_one :setting, dependent: :destroy
  has_many :link_tokens

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, uniqueness: true, presence: true
end
