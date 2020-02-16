# frozen_string_literal: true

# For 301 redirect.

if ENV['RACK_ENV'] == 'production'
  LineBot::Application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    # 新 URL に redirect する.
    r301 %r{.*}, 'https://linebot.o-char.com$&', if: proc { |rack_env|
      # rack_env['SERVER_NAME'] != 'linebot.o-char.com' &&
      rack_env['SERVER_NAME'] == 'char-line-bot.herokuapp.com'
    }
  end
end
