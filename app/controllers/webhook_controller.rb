# frozen_string_literal: true

require 'line/bot' # gem 'line-bot-api'

# WebhookController
# LINE からのリクエストに答えるコントローラ
class WebhookController < ApplicationController
  before_action :client, only: [:callback]

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery except: [:callback]

  # リッチメニューのID設定
  RICHMENU_ID = ENV['RICHMENU_ID']

  # LINE Client から送信(POSTリクエスト)が来た場合の動作
  def callback
    body = request.body.read

    # 署名の検証(production 環境のみ)
    if Rails.env.production?
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless @client.validate_signature(body, signature)
        return head :bad_request
      end
    end

    events = @client.parse_events_from(body)
    return head :bad_request unless validate_events(events)

    events.each do |event|
      logger.info event
      get_model(event)
      create_wh_event(event)

      case event
      when Line::Bot::Event::Message # message event
        # 送信ユーザとリッチメニューをリンクする
        link_menu
        case event.type
        when Line::Bot::Event::MessageType::Text # テキスト
          input_text = event.message['text']
          case input_text
          when 'change-to-char'
            @user.update(masa: false, suffix: 'チャー')
            output_text = 'チャーに切替'
          when 'change-to-masa'
            @user.update(masa: true, suffix: 'まさ')
            output_text = 'まさに切替'
          when 'メニュー追加'
            if @user.linked
              output_text = 'リッチメニューはすでに追加されています。'
            else
              # 送信ユーザとリッチメニューをリンクする
              @user.update(linked: true)
              link_menu
              output_text = "リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。"
            end
          when 'メニュー削除'
            if @user.linked
              # リッチメニューとのリンクを削除する
              @user.update(linked: false)
              unlink_menu
              output_text = "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
            else
              output_text = 'リッチメニューはすでに削除されています。'
            end
          else
            output_text = input_text + @user&.suffix
          end
          @message = { type: 'text', text: output_text }
          # 送信
          logger.info "Send #{@message}"
          @client.reply_message(event['replyToken'], @message)
        when Line::Bot::Event::MessageType::Sticker # スタンプ
          output_text = 'おもしろいスタンプだ' + @user&.suffix + '！'
          @message = { type: 'text', text: output_text }
          # 送信
          logger.info "Send #{@message}"
          @client.reply_message(event['replyToken'], @message)
        end
      when Line::Bot::Event::Follow # follow event
        # 送信ユーザとリッチメニューをリンクする
        link_menu
        logger.info 'Followed or Unblocked.'
      when Line::Bot::Event::Unfollow # blocked event
        unlink_menu
        logger.info 'Blocked.'
      when Line::Bot::Event::Leave # グループから退出したときのevent
        logger.info 'Group left.'
      end
    end
    head :ok
  end

  private

  # events の各 event に共通プロパティなどの必須項目が入ってるか検証
  def validate_events(events)
    events.each do |event|
      # 共通プロパティ
      if event['type'].nil? || event['timestamp'].nil? || event['source'].nil?
        return false
      end
      # source 下で必ず存在するプロパティ
      if event['source']['type'].nil? || event['source']['userId'].nil?
        return false
      end
    end
    true
  end

  # ユーザ, トークルーム, グループのモデルをDBから取得して返す
  def get_model(event)
    source = event['source']
    @user = User.get_by(source['userId'])
    @room = Room.get_by(source['roomId']) unless source['roomId'].nil?
    @group = Group.get_by(source['groupId']) unless source['groupId'].nil?
    @user
  end

  # WebhookEvent モデルを生成する
  def create_wh_event(event)
    @wh_event = WebhookEvent.create(
      event_type: event['type'],
      timestamp: event['timestamp'],
      source_type: event['source']['type'],
      user_id: @user.id,
      room_id: @room&.id,
      talk_group_id: @group&.id
    )
    return unless @wh_event.event_type == 'message'
    Message.create(
      reply_token: event['replyToken'],
      message_id: event['message']['id'],
      message_type: event['message']['type'],
      text: event['message']['text'],
      webhook_event: @wh_event
    )
  end

  # 環境変数から @client を生成
  def client
    @client ||= Line::Bot::Client.new do |config|
      # シークレットとアクセストークンの設定
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  # 送信ユーザとリッチメニューをリンクする
  def link_menu
    return unless @user&.linked
    res = link_menu_request(true)
    logger.info "Linked. #{res.code} #{res.body}"
  end

  # 送信ユーザとリッチメニューのリンクを削除する
  def unlink_menu
    return if @user&.linked
    res = link_menu_request(false)
    logger.info "Link deleted. #{res.code} #{res.body}"
  end

  def link_menu_request(link)
    uri_s = if link
              "/#{@user&.user_id}/richmenu/#{RICHMENU_ID}"
            else
              "/#{@user&.user_id}/richmenu"
            end
    uri = URI.parse('https://api.line.me/v2/bot/user' + uri_s)
    header = { 'Authorization': "Bearer #{@client.channel_token}" }
    req = if link
            Net::HTTP::Post.new(uri.path, header)
          else
            Net::HTTP::Delete.new(uri.path, header)
          end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do |h|
      h.request(req)
    end
  end
end
