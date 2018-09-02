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

  def self.get_by(talk_group_id)
    # トークグループをDBから取得して返す
    talk_group = TalkGroup.find_by(group_id: talk_group_id)
    # グループIDがデータベースに追加されていなければ追加する
    if talk_group.nil?
      logger.info 'create new TalkGroup'
      talk_group = TalkGroup.create(group_id: talk_group_id)
    else
      logger.info 'Registered TalkGroup.'
    end
    talk_group
  end
end
