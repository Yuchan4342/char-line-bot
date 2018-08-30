# frozen_string_literal: true

# == Schema Information
#
# Table name: talk_groups
#
#  id         :bigint(8)        not null, primary key
#  group_id   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# TalkGroup クラス: LINE でのグループ
class TalkGroup < ApplicationRecord
  has_many :webhook_events, dependent: :nullify
end
