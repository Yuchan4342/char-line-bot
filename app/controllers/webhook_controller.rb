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
    if Rails.env.production? && !validate_signature(body, request)
      return head :bad_request
    end

    events = @client.parse_events_from(body)
    return head :bad_request unless validate_events(events)

    process_events(events)
    head :ok
  end

  private

  # 環境変数から @client を生成
  def client
    @client ||= Line::Bot::Client.new do |config|
      # シークレットとアクセストークンの設定
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  # 署名の検証を行う
  # @param body 検証を行う request の body
  def validate_signature(body, request)
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    @client.validate_signature(body, signature)
  end

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
    @room = Room.get_by(source['roomId']) if source['type'] == 'room'
    @group = Group.get_by(source['groupId']) if source['type'] == 'group'
    create_wh_event(event)
  end

  # WebhookEvent モデル @wh_event を生成する
  # @param event: @wh_event に入れたい json データ.
  def create_wh_event(event)
    @wh_event = WebhookEvent.create(
      event_type: event['type'],
      timestamp: event['timestamp'],
      source_type: event['source']['type'],
      user_id: @user.id,
      room_id: @room&.id,
      talk_group_id: @group&.id
    )
    create_message(event) if @wh_event.event_type == 'message'
  end

  # @wh_event に関連する Messageモデルを生成する.
  # @param event: 生成するモデルに入れたい json データ.
  def create_message(event)
    Message.create(
      reply_token: event['replyToken'],
      message_id: event['message']['id'],
      message_type: event['message']['type'],
      text: event['message']['text'],
      webhook_event: @wh_event
    )
  end

  # events に対するループ処理
  # @param events 処理したいイベントの配列
  def process_events(events)
    events.each do |event|
      logger.info event
      get_model(event)
      process_event(event)
    end
  end

  # 各 event に対する処理
  # @param event 処理したいイベント
  def process_event(event)
    case event['type']
    # message event
    when 'message' then link_menu
                        reply_to_message_event(event)
    # follow event
    when 'follow' then link_menu
                       logger.info 'Followed or Unblocked.'
    # blocked event
    when 'unfollow' then unlink_menu
                         logger.info 'Blocked.'
    # グループに参加したときのevent
    when 'join' then logger.info 'Joined group or room.'
    # グループから退出したときのevent
    when 'leave' then logger.info 'Left group or room.'
    end
  end

  def reply_to_message_event(event)
    return unless event['type'] == 'message'

    reply_token = event['reply_token']
    case event['message']['type']
    when 'text' # テキスト
      send_message(reply_token, reply_to_text(event['message']['text']))
    # when 'image' # 画像
    # when 'video' # 映像
    # when 'audio' # 音声
    # when 'file' # ファイル
    # when 'location' # 位置情報
    when 'sticker' # スタンプ
      send_message(reply_token, 'おもしろいスタンプだ' + @user&.suffix + '！')
    end
  end

  # text メッセージを受け取った場合の処理.
  # @param text 受け取ったテキスト
  # @return 返すテキストメッセージ
  def reply_to_text(input_text)
    case input_text
    when 'change-to-char', 'change-to-masa'
      suffix = input_text == 'change-to-char' ? 'チャー' : 'まさ'
      @user.update(suffix: suffix)
      return "#{suffix}に切替"
    when 'メニュー追加', 'メニュー削除'
      process_link_unlink_menu(input_text == 'メニュー追加')
    else
      input_text + @user&.suffix
    end
  end

  # 'メニュー追加', 'メニュー削除' に対する処理.
  # @param is_add テキストが 'メニュー追加' であるかどうか
  # @return 返すテキストメッセージ
  def process_link_unlink_menu(is_add)
    return 'リッチメニューはすでに追加されています。' if @user.linked && is_add
    return 'リッチメニューはすでに削除されています。' if !@user.linked && !is_add

    @user.update(linked: is_add)
    if is_add
      # 送信ユーザとリッチメニューをリンクする
      link_menu
      "リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。"
    else
      # リッチメニューとのリンクを削除する
      unlink_menu
      "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
    end
  end

  # メッセージを送信する.
  def send_message(token, text)
    @message = { type: 'text', text: text }
    logger.info "Send #{@message}"
    @client.reply_message(token, @message)
  end

  # 送信ユーザとリッチメニューをリンクする
  def link_menu
    return unless @user&.linked

    res = @client.link_user_rich_menu(@user&.user_id, RICHMENU_ID)
    logger.info "Linked. #{res.code} #{res.body}"
  end

  # 送信ユーザとリッチメニューのリンクを削除する
  def unlink_menu
    return if @user&.linked

    res = @client.unlink_user_rich_menu(@user&.user_id)
    logger.info "Link deleted. #{res.code} #{res.body}"
  end
end
