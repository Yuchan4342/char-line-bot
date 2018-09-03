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

require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  # get_by で指定の room_id を持つモデルが取得できることをテスト
  test 'get_by 存在する場合' do
    room_id = 'hogehoge01'
    room = Room.get_by(room_id)
    assert_not_nil room
    assert_equal rooms(:one), room
  end

  # get_by で新規に指定の room_id を持つモデルが生成されることをテスト
  test 'get_by 存在しない場合' do
    room_id = 'hogehoge02'
    assert_nil Room.find_by(room_id: room_id)
    room = Room.get_by(room_id)
    room_found = Room.find_by(room_id: room_id)
    assert_not_nil room_found
    assert_equal room, room_found
  end
end
