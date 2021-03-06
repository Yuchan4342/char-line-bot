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

  # change-string 関連
  test "'change-string'に対してメッセージ'うしろにつけたいテキストを送ってくださいチャー'を返す" do
    text = 'うしろにつけたいテキストを送ってくださいチャー'
    post callback_path, params: text_message_events('change-string')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test "'change-string'で属性 changing_suffix が true に切り替わる" do
    post callback_path, params: text_message_events('change-string')
    assert_response :success
    assert assigns(:user).changing_suffix
  end

  test "'change-string'を送った後に一般のメッセージを送ったとき" do
    text = 'ほげに切り替えました！'
    post callback_path, params: text_message_events('ほげ', 'hoge3')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
    assert_not assigns(:user).changing_suffix
    assert_equal assigns(:user).suffix, 'ほげ'
  end

  test "'change-string'を送った後にメッセージ'change-to-char'を送ったとき" do
    text = 'チャーに切り替えました！'
    post callback_path, params: text_message_events('change-to-char', 'hoge3')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
    assert_not assigns(:user).changing_suffix
    assert_equal assigns(:user).suffix, 'チャー'
  end

  test "'change-string'を送った後にメッセージ'change-to-masa'を送ったとき" do
    text = 'まさに切り替えました！'
    post callback_path, params: text_message_events('change-to-masa', 'hoge3')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
    assert_not assigns(:user).changing_suffix
    assert_equal assigns(:user).suffix, 'まさ'
  end

  # suffix 関連
  test 'メッセージを送ったときに属性 suffix が変更されていない' do
    post callback_path, params: text_message_events('HogeHoge')
    assert_equal assigns(:user).suffix, 'チャー'
    post callback_path, params: text_message_events('HogeHoge', 'hoge2')
    assert_equal assigns(:user).suffix, 'まさ'
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
