# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint(8)        not null, primary key
#  reply_token      :string
#  message_id       :string
#  type             :string
#  text             :string
#  webhook_event_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

# Message
class Message < ApplicationRecord
  belongs_to :webhook_event
end
