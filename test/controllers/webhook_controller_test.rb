# frozen_string_literal: true

require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test 'post message to callback' do
    text = 'HogeHogeチャー'
    post '/callback', params: text_message_event('HogeHoge')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
  end

  test 'post link menu to callback' do
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

  test 'post unlink menu to callback' do
    # linked = true (リッチメニューが追加されている)の場合
    post '/callback', params: text_message_event('メニュー削除')
    assert_response :success
    text1 = "リッチメニューを削除しました。\n追加したいときは「メニュー追加」と送ってください。"
    assert_equal reply_message(text1), assigns(:message)
    assert_not assigns(:user).linked

    # linked = false (リッチメニューが追加されていない)の場合
    post '/callback', params: text_message_event('メニュー削除')
    assert_response :success
    text2 = 'リッチメニューはすでに削除されています。'
    assert_equal reply_message(text2), assigns(:message)
    assert_not assigns(:user).linked
  end
end
