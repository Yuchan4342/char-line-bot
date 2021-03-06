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

  def self.get_by(room_id)
    # トークルームをDBから取得して返す
    room = Room.find_by(room_id: room_id)
    # ルームIDがデータベースに追加されていなければ追加する
    if room.nil?
      logger.info 'create new Room'
      room = Room.create(room_id: room_id)
    else
      logger.info 'Registered Room.'
    end
    room
  end
end
