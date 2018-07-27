# frozen_string_literal: true

# WebhookController
# LINE からのリクエストに答えるコントローラ
class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  # リッチメニューのID設定 
  RICHMENU_ID = ENV['RICHMENU_ID']

  def client
    @client ||= Line::Bot::Client.new { |config|
      # シークレットとアクセストークンの設定
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  # 送信ユーザとリッチメニューをリンクする
  def link_menu (userId)
    if User.find_by(user_id: userId).linked
      uri = URI.parse("https://api.line.me/v2/bot/user/#{userId}/richmenu/#{RICHMENU_ID}")
      header = {'Authorization': "Bearer #{client.channel_token}"}

      req = Net::HTTP::Post.new(uri.path, header)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      res = http.start do |http|
        http.request(req)
      end
      puts "Linked. #{res.code} #{res.body}"
    end
  end

  def unlink_menu (userId)
    uri = URI.parse("https://api.line.me/v2/bot/user/#{userId}/richmenu")
    header = {'Authorization': "Bearer #{client.channel_token}"}

    req = Net::HTTP::Delete.new(uri.path, header)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
      
    res = http.start do |http|
      http.request(req)
    end
    puts "Link deleted. #{res.code} #{res.body}"
  end

  def callback
    body = request.body.read

    # 署名の検証
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each do |event|
      p event
      userId = event['source']['userId']
      user = User.find_by(user_id: userId)

      # ユーザIDがデータベースに追加されているかどうか
      if user
        p "Registered User. #{user&.user_name}"
      else
        p 'create new User'
        # ユーザIDをデータベースに追加する
        User.create(talk_type: event['source']['type'], user_id: userId, masa: false, linked: true)
      end

      case event
      when Line::Bot::Event::Message # message event
        # 送信ユーザとリッチメニューをリンクする
        link_menu(userId)
        case event.type
        when Line::Bot::Event::MessageType::Text # テキスト
          input_text = event.message['text']
          if input_text == 'change-to-char'
            user.update(masa: false)
            output_text = 'チャーに切替'
          elsif input_text == 'change-to-masa'
            user.update(masa: true)
            output_text = 'まさに切替'
          elsif input_text == 'メニュー追加'
            if user.linked
              output_text = 'リッチメニューはすでに追加されています。'
            else
              # 送信ユーザとリッチメニューをリンクする
              user.update(linked: true)
              link_menu(userId)
              output_text = 'リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。'
            end
          elsif input_text == 'メニュー削除'
            unless user.linked
              output_text = 'リッチメニューはすでに削除されています。'
            else
              # リッチメニューとのリンクを削除する
              user.update(linked: false)
              unlink_menu(userId)
              output_text = "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
            end
          else
            output_text = input_text + (user.masa ? 'まさ' : 'チャー')
          end
          message = { type: 'text', text: output_text }
          # 送信
          puts "Send #{message}"
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Sticker # スタンプ
          output_text = 'おもしろいスタンプだ' + (user.masa ? 'まさ' : 'チャー') + '！'
          message = { type: 'text', text: output_text }
          # 送信
          puts "Send #{message}"
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::Follow # follow event
        # 送信ユーザとリッチメニューをリンクする
        link_menu(userId)
        puts 'Followed or Unblocked.'
      when Line::Bot::Event::Unfollow # blocked event
        unlink_menu(userId)
        puts 'Blocked.'
      when Line::Bot::Event::Leave # グループから退出したときのevent
        puts 'Group left.'
      end
    end
    head :ok
  end
end
