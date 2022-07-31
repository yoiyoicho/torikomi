class Schedule < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, length: { maximum: 65535 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true
  validates :resource_type, presence: true
  validates :i_cal_uid, presence: true, if: :google?

  validate :start_time_cannot_be_in_the_past, on: :create_or_update
  validate :end_time_cannot_be_earier_than_start_time

  enum status: { draft: 0, to_be_sent: 1, sent: 2 }
  enum resource_type: { default: 0, google: 1 }

  def start_time_cannot_be_in_the_past
    if start_time < Time.zone.now
      errors.add(:start_time, "は現在より先の日時にしてください")
    end
  end

  def end_time_cannot_be_earier_than_start_time
    if end_time.present?
      if end_time < start_time
        errors.add(:end_time, "は開始日時より先の日時にしてください")
      end
    end
  end

  def create_line_message
    setting = self.user.setting

    message = "スケジュールをお知らせします！" + "\n"

    if setting.only_time?
      message << "\n" + "日時：" + self.start_time.strftime('%Y年%m月%d日 %H時%M分')
    elsif setting.time_and_title?
      message << "\n" + "日時：" + self.start_time.strftime('%Y年%m月%d日 %H時%M分')
      message << "\n" + "タイトル：" + self.title
    else # setting.time_and_title_and_body?
      message << "\n" + "日時：" + self.start_time.strftime('%Y年%m月%d日 %H時%M分')
      message << "\n" + "タイトル：" + self.title
      message << "\n" + "内容：" + self.body ||= "（未設定）"
    end

    if setting.message_text.present?
      message << "\n\n" + setting.message_text
    end

    message
  end
end
