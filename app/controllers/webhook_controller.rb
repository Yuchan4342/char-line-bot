# frozen_string_literal: true

# WebhookController
# LINE からのリクエストに答えるコントローラ
class WebhookController < ApplicationController
  require 'line/bot' # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery except: [:callback]

  # リッチメニューのID設定
  RICHMENU_ID = ENV['RICHMENU_ID']

  def client
    @client ||= Line::Bot::Client.new do |config|
      # シークレットとアクセストークンの設定
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  # LINE Client から送信(POSTリクエスト)が来た場合の動作
  def callback
    body = request.body.read

    # 署名の検証
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    user_ids = events.map { |e| e['source']['userId'] }
    @users = User.where(user_id: user_ids)

    events.each do |event|
      logger.info event
      user_id = event['source']['userId']
      @user = @users.find_by(user_id: user_id)

      # ユーザIDがデータベースに追加されているかどうか
      if @user
        logger.info "Registered User. #{@user&.user_name}"
      else
        logger.info 'create new User'
        # ユーザIDをデータベースに追加する
        User.create(
          talk_type: event['source']['type'],
          user_id: user_id,
          masa: false,
          linked: true
        )
      end

      case event
      when Line::Bot::Event::Message # message event
        # 送信ユーザとリッチメニューをリンクする
        link_menu
        case event.type
        when Line::Bot::Event::MessageType::Text # テキスト
          input_text = event.message['text']
          case input_text
          when 'change-to-char'
            @user.update(masa: false)
            output_text = 'チャーに切替'
          when 'change-to-masa'
            @user.update(masa: true)
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
            output_text = input_text + (@user&.masa ? 'まさ' : 'チャー')
          end
          @message = { type: 'text', text: output_text }
          # 送信
          logger.info "Send #{@message}"
          client.reply_message(event['replyToken'], @message)
        when Line::Bot::Event::MessageType::Sticker # スタンプ
          output_text = 'おもしろいスタンプだ' + (@user&.masa ? 'まさ' : 'チャー') + '！'
          @message = { type: 'text', text: output_text }
          # 送信
          logger.info "Send #{@message}"
          client.reply_message(event['replyToken'], @message)
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
    header = { 'Authorization': "Bearer #{client.channel_token}" }
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
