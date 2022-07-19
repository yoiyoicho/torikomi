class LineMessagingApiController < ApplicationController
  require 'line/bot'
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
          line_user_id = event['source']['userId']
          message = {
            type: 'text',
            text: event.message['text']
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
end