# frozen_string_literal: true

require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "メッセージに'チャー'をつけて返す" do
    text = 'HogeHogeチャー'
    post '/callback', params: text_message_event('HogeHoge')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "メッセージに'まさ'をつけて返す" do
    text = 'HogeHogeまさ'
    post '/callback', params: text_message_event('HogeHoge', 'hoge2')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "メニュー'メニュー追加'に対する動作" do
    # linked = true (リッチメニューがすでに追加されている)の場合
    post '/callback', params: text_message_event('メニュー追加')
    assert_response :success
    text1 = 'リッチメニューはすでに追加されています。'
    assert_equal reply_message(text1), assigns(:message)
    assert assigns(:user).linked

    # linked = false (リッチメニューが追加されていない)の場合
    post '/callback', params: text_message_event('メニュー追加', 'hoge2')
    assert_response :success
    text2 = "リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。"
    assert_equal reply_message(text2), assigns(:message)
    assert assigns(:user).linked
  end

  test "メニュー'メニュー削除'に対する動作" do
    # linked = true (リッチメニューが追加されている)の場合
    post '/callback', params: text_message_event('メニュー削除')
    assert_response :success
    text1 = "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
    assert_equal reply_message(text1), assigns(:message)
    assert_not assigns(:user).linked

    # linked = false (リッチメニューが追加されていない)の場合
    post '/callback', params: text_message_event('メニュー削除', 'hoge2')
    assert_response :success
    text2 = 'リッチメニューはすでに削除されています。'
    assert_equal reply_message(text2), assigns(:message)
    assert_not assigns(:user).linked
  end

  test "'change-to-masa'で属性 masa が true に切り替わる" do
    post '/callback', params: text_message_event('change-to-masa')
    assert_response :success
    text1 = 'まさに切替'
    assert_equal reply_message(text1), assigns(:message)
    assert assigns(:user).masa
  end

  test "'change-to-char'で属性 masa が false に切り替わる" do
    post '/callback', params: text_message_event('change-to-char', 'hoge2')
    assert_response :success
    text2 = 'チャーに切替'
    assert_equal reply_message(text2), assigns(:message)
    assert_not assigns(:user).masa
  end

  test 'メッセージを送ったときに masa が変更されていない' do
    post '/callback', params: text_message_event('HogeHoge')
    assert_not assigns(:user).masa
    post '/callback', params: text_message_event('HogeHoge', 'hoge2')
    assert assigns(:user).masa
  end

  test 'メッセージを送ったときに linked が変更されていない' do
    post '/callback', params: text_message_event('HogeHoge')
    assert assigns(:user).linked
    post '/callback', params: text_message_event('HogeHoge', 'hoge2')
    assert_not assigns(:user).linked
  end

  test 'フォローイベントで新規ユーザーが User に追加されている' do
    post '/callback', params: follow_event('hoge3')
    assert_not_nil User.find_by(user_id: 'hoge3')
  end

  # test 'イベントが WebhookEvent に追加されている' do
  #   old_wh_events = WebhookEvent.all
  #   post '/callback', params: text_message_event('HogeHoge', 'hoge2')
  #   assert_response :success
  #   new_wh_events = WebhookEvent.all
  #   assert_not_equal old_wh_events, new_wh_events
  # end
end
