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
  # test "the truth" do
  #   assert true
  # end
end
