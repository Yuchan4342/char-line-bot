# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml
  # for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here.
  def text_message_event(text, user_id = 'hoge1')
    {
      'events': [
        {
          'replyToken': '8cf9239d56244f4197887e939187e19e',
          'type': 'message',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': user_id
          },
          'message': {
            'id': '325709',
            'type': 'text',
            'text': text
          }
        }
      ]
    }.to_json
  end

  def follow_event(user_id = 'hoge3')
    {
      'events': [
        {
          'replyToken': 'nHuyWiB7yP5Zw52FIkcQobQuGDXCTA',
          'type': 'follow',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': user_id
          }
        }
      ]
    }.to_json
  end

  def reply_message(text)
    {
      type: 'text',
      text: text
    }
  end
end
