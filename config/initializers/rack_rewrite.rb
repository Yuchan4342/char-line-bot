# For 301 redirect.

if ENV['RACK_ENV'] == 'production'
  LineBot::Application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    # /callback のみ除外
    r301 %r{.*(?<!callback)$}, 'http://linebot.o-char.com$&', if: proc { |rack_env|
      rack_env['SERVER_NAME'] != 'linebot.o-char.com'
    }
  end
end
