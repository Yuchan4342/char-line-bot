# frozen_string_literal: true

require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "メッセージに'チャー'をつけて返す" do
    text = 'HogeHogeチャー'
    post callback_path, params: text_message_events('HogeHoge')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "メッセージに'まさ'をつけて返す" do
    text = 'HogeHogeまさ'
    post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "メニュー'メニュー追加'に対する動作" do
    # linked = true (リッチメニューがすでに追加されている)の場合
    post callback_path, params: text_message_events('メニュー追加')
    assert_response :success
    text1 = 'リッチメニューはすでに追加されています。'
    assert_equal reply_message(text1), assigns(:message)
    assert assigns(:user).linked

    # linked = false (リッチメニューが追加されていない)の場合
    post callback_path, params: text_message_events('メニュー追加', 'hoge2')
    assert_response :success
    text2 = "リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。"
    assert_equal reply_message(text2), assigns(:message)
    assert assigns(:user).linked
  end

  test "メニュー'メニュー削除'に対する動作" do
    # linked = true (リッチメニューが追加されている)の場合
    post callback_path, params: text_message_events('メニュー削除')
    assert_response :success
    text1 = "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
    assert_equal reply_message(text1), assigns(:message)
    assert_not assigns(:user).linked

    # linked = false (リッチメニューが追加されていない)の場合
    post callback_path, params: text_message_events('メニュー削除', 'hoge2')
    assert_response :success
    text2 = 'リッチメニューはすでに削除されています。'
    assert_equal reply_message(text2), assigns(:message)
    assert_not assigns(:user).linked
  end

  test "'change-to-masa'で属性 suffix が 'まさ' に切り替わる" do
    post callback_path, params: text_message_events('change-to-masa')
    assert_response :success
    text1 = 'まさに切り替えました！'
    assert_equal reply_message(text1), assigns(:message)
    assert_equal assigns(:user).suffix, 'まさ'
  end

  test "'change-to-char'で属性 suffix が 'チャー' に切り替わる" do
    post callback_path, params: text_message_events('change-to-char', 'hoge2')
    assert_response :success
    text2 = 'チャーに切り替えました！'
    assert_equal reply_message(text2), assigns(:message)
    assert_equal assigns(:user).suffix, 'チャー'
  end

  test "'change-string'に対してメッセージ'後ろに付けたい文字列を入れてくださいチャー'を返す" do
    text = '後ろに付けたい文字列を入れてくださいチャー'
    post callback_path, params: text_message_events('change-string')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "'change-string'で属性 changing_suffix が true に切り替わる" do
    post callback_path, params: text_message_events('change-string')
    assert_response :success
    assert assigns(:user).changing_suffix
  end

  test 'メッセージを送ったときに属性 suffix が変更されていない' do
    post callback_path, params: text_message_events('HogeHoge')
    assert_equal assigns(:user).suffix, 'チャー'
    post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    assert_equal assigns(:user).suffix, 'まさ'
  end

  test 'メッセージを送ったときに linked が変更されていない' do
    post callback_path, params: text_message_events('HogeHoge')
    assert assigns(:user).linked
    post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    assert_not assigns(:user).linked
  end

  test 'フォローイベントで新規ユーザーが User に追加されている' do
    post callback_path, params: follow_events('hoge3')
    assert_not_nil User.find_by(user_id: 'hoge3')
  end

  test 'イベントが WebhookEvent に追加されている' do
    assert_difference('WebhookEvent.count', 1) do
      post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    end
    assert_response :success
  end

  test 'イベントがメッセージのとき, メッセージが Message に追加されている' do
    assert_difference('Message.count', 1) do
      post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    end
    assert_response :success
    assert_equal assigns(:wh_event).message.text, 'HogeHoge'
  end
end
