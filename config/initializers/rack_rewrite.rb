# For 301 redirect.

if ENV['RACK_ENV'] == 'production'
  LineBot::Application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    r301 /%r{.*}/, 'http://linebot.o-char.com$&', if: proc { |rack_env|
      rack_env['SERVER_NAME'] == 'char-line-bot.herokuapp.com'
    }
  end
end
