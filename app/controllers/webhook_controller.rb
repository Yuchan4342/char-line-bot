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
      config.channel_token = if Rails.env.test?
                               'channel_token'
                             else
                               ENV['LINE_CHANNEL_TOKEN']
                             end
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
    when 'message' then reply_to_message_event(event)
    # follow event
    when 'follow' then logger.info 'Followed or Unblocked.'
    # blocked event
    when 'unfollow' then logger.info 'Blocked.'
    # グループに参加したときのevent
    when 'join' then logger.info 'Joined group or room.'
    # グループから退出したときのevent
    when 'leave' then logger.info 'Left group or room.'
    end
  end

  def reply_to_message_event(event)
    return unless event['type'] == 'message'

    reply_token = event['replyToken']
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
  # @param [String] input_text 受け取ったテキスト
  # @return [String] 返すテキストメッセージ
  def reply_to_text(input_text)
    case input_text
    when 'change-string'
      reply_to_change_string
    when 'change-to-char', 'change-to-masa'
      suffix = input_text == 'change-to-char' ? 'チャー' : 'まさ'
      @user.update(suffix: suffix, changing_suffix: false)
      "#{suffix}に切り替えました！"
    else
      if @user.changing_suffix
        change_suffix_and_reply(input_text)
      else
        input_text + @user&.suffix
      end
    end
  end

  # メッセージ 'change-string' を受け取った場合の処理.
  # @return [String] 返すテキストメッセージ
  def reply_to_change_string
    @user.update(changing_suffix: true)
    '後ろに付けたい文字列を入れてくださいチャー'
  end

  # 後ろに付ける文字列を設定してテキストメッセージを返す.
  # @param [String] new_suffix 新しく後ろに付ける文字列
  # @return [String] 返すテキストメッセージ
  def change_suffix_and_reply(new_suffix)
    @user.update(suffix: new_suffix, changing_suffix: false)
    "#{new_suffix}に切り替えました！"
  end

  # メッセージを送信する.
  def send_message(token, text)
    @message = { type: 'text', text: text }
    logger.info "Send #{@message}"
    @client.reply_message(token, @message)
  end
end
