# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint(8)        not null, primary key
#  user_id    :string
#  masa       :boolean
#  linked     :boolean
#  user_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  suffix     :string
#

# User クラス: Bot にイベントを送ったユーザ情報を保存する
class User < ApplicationRecord
  has_many :webhook_events, dependent: :nullify

  def self.get_by(user_id)
    # ユーザをDBから取得して返す
    user = User.find_by(user_id: user_id)
    # ユーザIDがデータベースに追加されていなければ追加する
    if user.nil?
      logger.info 'create new User'
      user = User.create(
        user_id: user_id,
        masa: false,
        linked: true
      )
    else
      logger.info "Registered User. #{user&.user_name}"
    end
    user
  end
end
