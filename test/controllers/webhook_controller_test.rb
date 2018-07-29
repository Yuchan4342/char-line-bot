# frozen_string_literal: true

require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test 'post callback' do
    json = {
      'events': [
        {
          'replyToken': '0f3779fba3b349968c5d07db31eab56f',
          'type': 'message',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': 'hoge1'
          },
          'message': {
            'id': '325708',
            'type': 'text',
            'text': 'Hello, world'
          }
        },
        {
          'replyToken': '8cf9239d56244f4197887e939187e19e',
          'type': 'message',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': 'hoge1'
          },
          'message': {
            'id': '325709',
            'type': 'text',
            'text': 'HogeHoge'
          }
        }
      ]
    }.to_json
    # uri = URI.parse('http://localhost:3000/callback')
    # http = Net::HTTP.new(uri.host, uri.port)
    # req = Net::HTTP::Post.new(uri.path)
    # req.body = json
    # res = http.request(req)
    # assert_equal('200', res.code)
  end
end
