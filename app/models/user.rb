class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :schedules, dependent: :destroy
  has_many :user_line_user_relationships, dependent: :destroy
  has_many :line_users, through: :user_line_user_relationships
  has_one :setting, dependent: :destroy
  has_many :link_tokens

  validates :password, length: { minimum: 3 }, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :password, confirmation: true, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :password_confirmation, presence: true, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :email, presence: true, uniqueness: { scope: :login_type }

  enum login_type: { default: 0, google: 1 }
end
