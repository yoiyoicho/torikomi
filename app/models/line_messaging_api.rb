# アプリとLINE Messaging APIの間で通信を行うモデル
# https://github.com/line/line-bot-sdk-ruby

require 'line/bot'

class LineMessagingApi

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def send_broadcast_message(text)
    message = {
      type: 'text',
      text: text
    }
    client.broadcast(message)
  end
end