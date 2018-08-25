# frozen_string_literal: true

# == Schema Information
#
# Table name: webhook_events
#
#  id            :bigint(8)        not null, primary key
#  type          :string
#  timestamp     :bigint(8)
#  source_type   :string
#  user_id       :bigint(8)
#  room_id       :bigint(8)
#  talk_group_id :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Event モデル: Bot に来たイベントを保存する
class WebhookEvent < ApplicationRecord
  belongs_to :user
end
