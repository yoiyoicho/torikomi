class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :schedules, dependent: :destroy
  has_many :user_line_user_relationships, dependent: :destroy
  has_many :line_users, through: :user_line_user_relationships
  has_one :setting, dependent: :destroy
  has_many :link_tokens, dependent: :destroy
  has_one :google_calendar_token, dependent: :destroy
  has_one :google_calendar_setting, dependent: :destroy

  validates :password, length: { minimum: 3 }, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :password, confirmation: true, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :password_confirmation, presence: true, if: -> { default? && (new_record? || changes[:crypted_password]) }
  validates :email, presence: true, uniqueness: { scope: :login_type }

  enum login_type: { default: 0, google: 1 }

  after_save :create_user_settings

  def my_object?(object)
    object.user_id == id
  end

  private

  def create_user_settings
    self.build_setting.save! if self.setting.blank?
    self.build_google_calendar_setting.save! if self.google_calendar_setting.blank?
  end
end
