require 'line/bot'

class WebhookController < ApplicationController
  # Lineからのcallbackか認証
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_TOKEN']
  RICHMENU_ID = ENV['RICHMENU_ID']
  
  @@behind_text = "チャー"
  @@masa_array = []

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    event = params["events"][0]
    event_type = event["type"]
    replyToken = event["replyToken"]
    userId = event["source"]["userId"]
    
    # show user rich menu
    uri = URI.parse("https://api.line.me/v2/bot/user/#{userId}/richmenu/#{RICHMENU_ID}")
    header = {'Authorization': "Bearer #{CHANNEL_ACCESS_TOKEN}"}
    
    req = Net::HTTP::Post.new(uri.path, header)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    res = http.start do |http|
        http.request(req)
    end
    puts res.code
    puts res.body

    case event_type
    when "message"
      input_text = event["message"]["text"]
      if input_text == "change-to-char" then
        # @@behind_text = "チャー"
        @@masa_array.delete(userId)
        output_text = "チャーに切替"
      elsif input_text == "change-to-masa" then
        # @@behind_text = "まさ"
        @@masa_array << userId
        output_text = "まさに切替"
      else
      # output_text = input_text
        if @@masa_array.include?(userId) then
          output_text = input_text + "まさ"
        else
          output_text = input_text + "チャー"
        end
      end
    end

    client = LineClient.new(CHANNEL_SECRET, CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, output_text)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    render :nothing => true, status: :ok
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
