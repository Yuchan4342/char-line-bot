class LineClient
  END_POINT = "https://api.line.me"

  def initialize(channel_secret, channel_access_token, proxy = nil)
    @channel_secret = channel_secret
    @channel_access_token = channel_access_token
    @proxy = proxy
  end

  def post(path, data)
    # client = Faraday.new(:url => END_POINT) do |conn|
    #   conn.request :json
    #   conn.response :json, :content_type => /\bjson$/
    #   conn.adapter Faraday.default_adapter
    #   conn.proxy @proxy
    # end

    # res = client.post do |request|
    #   request.url path
    #   request.headers = {
    #     'Content-type' => 'application/json',
    #     'Authorization' => "Bearer #{@channel_access_token}"
    #   }
    #   request.body = data
    # end
    # res
    client = Line::Bot::Client.new { |config|
      config.channel_secret = @channel_secret
      config.channel_token = @channel_access_token
    }
    response = client.reply_message(data["replyToken"], data["messages"])
    p response
  end

  def reply(replyToken, text)

    messages = [
      {
        "type" => "text" ,
        "text" => text
      }
    ]

    body = {
      "replyToken" => replyToken ,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end

end