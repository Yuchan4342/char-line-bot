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

require 'test_helper'

class TalkGroupTest < ActiveSupport::TestCase
  # get_by で指定の group_id を持つモデルが取得できることをテスト
  test 'get_by 存在する場合' do
    group_id = 'hogehoge01'
    group = TalkGroup.get_by(group_id)
    assert_not_nil group
    assert_equal talk_groups(:one), group
  end

  # get_by で新規に指定の group_id を持つモデルが生成されることをテスト
  test 'get_by 存在しない場合' do
    group_id = 'hogehoge02'
    assert_nil TalkGroup.find_by(group_id: group_id)
    group = TalkGroup.get_by(group_id)
    group_found = TalkGroup.find_by(group_id: group_id)
    assert_not_nil group_found
    assert_equal group, group_found
  end
end
