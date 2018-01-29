require 'line/bot'

class WebhookController < ApplicationController
  # Lineからのcallbackか認証
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_TOKEN']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    event = params["events"][0]
    event_type = event["type"]
    replyToken = event["replyToken"]

    case event_type
    # when "message"
    when Line::Bot::Event::Message
      input_text = event["message"]["text"]
      # output_text = input_text
      output_text = input_text + "チャー"
      # output_text = input_text + "まさ"
    end

    client = LineClient.new(CHANNEL_SECRET, CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, output_text)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    render :nothing => true, status: :ok
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
