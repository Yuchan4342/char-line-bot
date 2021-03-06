# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml
    # for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here.
    def text_message_events(text, user_id = 'hoge1')
      {
        'events': [
          text_message_event(text, user_id)
        ]
      }.to_json
    end

    def text_message_event(text, user_id = 'hoge1')
      {
        'replyToken': '8cf9239d56244f4197887e939187e19e',
        'type': 'message',
        'timestamp': 1_462_629_479_859,
        'source': {
          'type': 'user',
          'userId': user_id
        },
        'message': text_message(text)
      }
    end

    def text_message(text)
      {
        'id': '325709',
        'type': 'text',
        'text': text
      }
    end

    def follow_events(user_id = 'hoge3')
      {
        'events': [
          follow_event(user_id)
        ]
      }.to_json
    end

    def follow_event(user_id = 'hoge3')
      {
        'replyToken': 'nHuyWiB7yP5Zw52FIkcQobQuGDXCTA',
        'type': 'follow',
        'timestamp': 1_462_629_479_859,
        'source': {
          'type': 'user',
          'userId': user_id
        }
      }
    end

    def reply_message(text)
      {
        type: 'text',
        text: text
      }
    end
  end
end
