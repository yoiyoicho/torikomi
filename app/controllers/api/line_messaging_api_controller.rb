class Api::LineMessagingApiController < ApplicationController
  require 'line/bot'
  require 'json'
  require 'typhoeus'

  # 外部からのPOSTリクエストを受けるためにCSRF対策を外す
  protect_from_forgery except: :callback
  skip_before_action :require_login

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      header_only(:bad_request)
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          line_user = LineUser.new

          # LINEユーザーのuserIDを取得
          line_user_id = event['source']['userId']
          line_user.assign_attributes(line_user_id: line_user_id)

          # LINEユーザーのプロフィールを取得
          profile = get_line_user_profile(line_user_id)
          line_user.assign_attributes(profile)

          # LINEユーザーから送られたワンタイムパスワードから、対応するトリコミのユーザーを見つける
          otp = event.message['text']
          hotp = ROTP::HOTP.new(ENV['OTP_SECRET'])
          User.all.each do |user|
            if hotp.verify(otp, user.id)
              line_user.user_id = user.id
            end
          end

          # LINEユーザーをデータベースに保存する
          if line_user.save
            response_text = '成功しました'
          else
            response_text = '失敗しました'
          end
          message = {
            type: 'text',
            text: response_text
          }
          client.push_message(line_user_id, message)
        end
      end
    end
    head :ok
  end

  def send_broadcast_message(text)
    message = {
      type: 'text',
      text: text
    }
    client.broadcast(message)
  end

  def send_push_message_by_schedule_id(schedule_id)
    schedule = Schedule.find(schedule_id)
    message = {
      type: 'text',
      text: schedule.create_line_message
    }
    schedule.user.line_users.each do |line_user|
      client.push_message(line_user.line_user_id, message)
    end
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def get_line_user_profile(line_user_id)
    url = "https://api.line.me/v2/bot/profile/:line_user_id".gsub(':line_user_id', line_user_id)
    options = {
      method: 'get',
      headers: {
        "Authorization" => "Bearer #{ENV['LINE_CHANNEL_TOKEN']}"
      },
    }
    request = Typhoeus::Request.new(url, options)
    response = request.run
    
    if response.code == 200
      { display_name: JSON.parse(response.body)['displayName'], picture_url: JSON.parse(response.body)['pictureUrl']||=nil }
    else
      {}
    end
  end
end