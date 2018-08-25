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

require 'test_helper'

class WebhookEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
