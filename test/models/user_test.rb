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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # get_by で指定の user_id を持つモデルが取得できることをテスト
  test 'get_by 存在する場合' do
    user_id = 'hoge1'
    user = User.get_by(user_id)
    assert_not_nil user
    assert_equal User.find(101), user
  end

  # get_by で新規に指定の user_id を持つモデルが生成されることをテスト
  test 'get_by 存在しない場合' do
    user_id = 'hogehoge1'
    assert_nil User.find_by(user_id: user_id)
    user = User.get_by(user_id)
    user_found = User.find_by(user_id: user_id)
    assert_not_nil user_found
    assert_equal user, user_found
  end
end
