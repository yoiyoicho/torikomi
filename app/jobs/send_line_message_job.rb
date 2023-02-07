class SendLineMessageJob < ApplicationJob
  require 'line/bot'
  require 'json'
  require 'typhoeus'

  queue_as :default

  def perform(*arg)
    send_push_message_by_schedule_id(arg[0])
  end

  private

  def send_push_message_by_schedule_id(schedule_id)
    schedule = Schedule.find(schedule_id)
    message = {
      type: 'text',
      text: create_line_message(schedule)
    }
    schedule.user.line_users.each do |line_user|
      client.push_message(line_user.line_user_id, message)
    end
    schedule.update!(status: :sent, sent_at: Time.zone.now)
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def create_line_message(schedule)
    setting = schedule.user.setting

    message = "スケジュールをお知らせします！" + "\n"

    if setting.only_time?
      message << "\n" + "日時：" + schedule.start_time.strftime('%Y年%m月%d日 %H時%M分')
    elsif setting.time_and_title?
      message << "\n" + "日時：" + schedule.start_time.strftime('%Y年%m月%d日 %H時%M分')
      message << "\n" + "タイトル：" + schedule.title
    else # setting.time_and_title_and_body?
      message << "\n" + "日時：" + schedule.start_time.strftime('%Y年%m月%d日 %H時%M分')
      message << "\n" + "タイトル：" + schedule.title
      message << "\n" + "内容：" + schedule.body ||= "（未設定）"
    end

    if setting.message_text.present?
      message << "\n\n" + setting.message_text
    end

    message
  end
end
