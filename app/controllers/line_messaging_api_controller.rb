class LineMessagingApiController < ApplicationController
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

          # LINEユーザーのプロフィールを取得
          profile = get_line_user_profile(line_user_id)
          display_name = event['source']['displayName']
          if event['source']['pictureUrl'].present?
            picture_url = event['source']['pictureUrl']
          end

          # LINEユーザーから送られたワンタイムパスワードから、対応するトリコミのユーザーを見つける
          otp = event.message['text']
          hotp = ROTP::HOTP.new(ENV['OTP_SECRET'])
          User.all.each do |user|
            if hotp.verify(otp, user.id)
              user_id = user.id
            end
          end

          # LINEユーザーをデータベースに保存する
          line_user.assign_attributes(user_id: user_id||=nil, line_user_id: line_user_id, display_name: display_name, picture_url: picture_url||=nil)
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
        "Authorization" => "Bearer #{ENV['CHANNEL_ACCESS_TOKEN']}"
      },
    }
    request = Typhoeus::Request.new(url, options)
    response = request.run
    if response.code == 200
      binding.pry
      JSON.parse(response.body)
    else
      nil
    end
  end
end