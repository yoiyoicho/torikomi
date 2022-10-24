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
      text: schedule.create_line_message
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
end
