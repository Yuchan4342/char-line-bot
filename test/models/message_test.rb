# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint(8)        not null, primary key
#  reply_token      :string
#  message_id       :string
#  message_type     :string
#  text             :string
#  webhook_event_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'webhook_event_id = nil では create できない' do
    Message.create(id: 101, webhook_event_id: nil)
    assert_nil Message.find_by(id: 101)
  end

  test 'webhook_event_id = 2 では create できる' do
    message = Message.create(id: 101, webhook_event_id: 2)
    message_found = Message.find_by(id: 101)
    assert_not_nil message_found
    assert_equal message, message_found
  end
  
  test 'webhook_event_id を重複させては create できない' do
    Message.create(id: 101, webhook_event_id: 1)
    assert_nil Message.find_by(id: 101)
  end
end
