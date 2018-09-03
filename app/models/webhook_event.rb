# frozen_string_literal: true

# == Schema Information
#
# Table name: webhook_events
#
#  id            :bigint(8)        not null, primary key
#  event_type    :string
#  timestamp     :bigint(8)
#  source_type   :string
#  user_id       :bigint(8)
#  room_id       :bigint(8)
#  talk_group_id :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# WebhookEvent モデル: Bot に来た Webhook イベントを保存する
class WebhookEvent < ApplicationRecord
  belongs_to :user
  belongs_to :room, optional: true
  belongs_to :talk_group, optional: true

  has_one :message, dependent: :destroy
end
