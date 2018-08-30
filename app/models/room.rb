# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id         :bigint(8)        not null, primary key
#  room_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Room クラス: LINE でのトークルーム(グループトーク)
class Room < ApplicationRecord
  has_many :webhook_events, dependent: :nullify
end
