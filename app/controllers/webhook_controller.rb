class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  @@behind_text = "チャー"
  @@masa_array = []

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      userId = event.source['userId']
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input_text = event.message['text']
          if input_text == "change-to-char" then
            @@masa_array.delete(userId)
            output_text = "チャーに切替"
          elsif input_text == "change-to-masa" then
            @@masa_array << userId
            output_text = "まさに切替"
          else
            if @@masa_array.include?(userId) then
              output_text = input_text + "まさ"
            else
              output_text = input_text + "チャー"
            end
          end
          message = {
            type: 'text',
            text:  output_text
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end

  private
  # verify access from LINE
  def is_validate_signature
    signature = request.headers["X-Line-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end
