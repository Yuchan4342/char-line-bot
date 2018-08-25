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
#

# User クラス: Bot にイベントを送ったユーザ情報を保存する
class User < ApplicationRecord
  has_many :webhook_events, dependent: :nullify
end
