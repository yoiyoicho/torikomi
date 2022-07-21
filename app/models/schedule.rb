class Schedule < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, length: { maximum: 65535 }
  validates :start_time, presence: true

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
