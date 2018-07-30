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
    text = "リッチメニューを追加しました。\n削除したいときは「メニュー削除」と送ってください。"
    post '/callback', params: text_message_event('メニュー追加')
    assert_response :success
    assert_equal reply_message(text), assigns(:message)
    assert assigns(:user).linked
  end
end
