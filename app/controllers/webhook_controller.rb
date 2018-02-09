class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  # リッチメニューのID設定 
  RICHMENU_ID = ENV['RICHMENU_ID']

  @@behind_text = "チャー"
  @@masa_array = []

  def client
    @client ||= Line::Bot::Client.new { |config|
      # シークレットとアクセストークンの設定
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    # 署名の検証
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      userId = event['source']['userId']

      # ユーザIDがデータベースに追加されているかどうか  
      if Webhook.find_by(user_id: userId) then
        puts "This user id is always registered in this database."
      else
        # 送信ユーザとリッチメニューをリンクする
        uri = URI.parse("https://api.line.me/v2/bot/user/#{userId}/richmenu/#{RICHMENU_ID}")
        header = {'Authorization': "Bearer #{@client.channel_token}"}

        req = Net::HTTP::Post.new(uri.path, header)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
      
        res = http.start do |http|
          http.request(req)
        end

        # ユーザIDをデータベースに追加する
        wh = Webhook.new
        wh.type = event['source']['type']
        wh.user_id = userId
        wh.masa = false
        wh.save
      end

      puts "#{res.code} #{res.body}"

      case event
      when Line::Bot::Event::Message # message event  
        case event.type
        when Line::Bot::Event::MessageType::Text # テキスト
          input_text = event.message['text']
          if input_text == "change-to-char" then
            # @webhook = Webhook.find_by(user_id: userId)
            # @webhook.masa = false
            # @webhook.save
            @@masa_array.delete(userId)
            output_text = "チャーに切替"
          elsif input_text == "change-to-masa" then
            # @webhook = Webhook.find_by(user_id: userId)
            # @webhook.masa = true
            # @webhook.save
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
          # 送信
          puts "Send #{message}"
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
