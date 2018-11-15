# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :ensure_domain

  def ensure_domain
    return unless /\.herokuapp.com/ =~ request.host

    # 主にlocalテスト用の対策80と443以外でアクセスされた場合ポート番号をURLに含める.
    port = ":#{request.port}" unless [80, 443].include?(request.port)
    redirect_to "http://#{FQDN}#{port}#{request.path}",
                status: :moved_permane
  end
end
