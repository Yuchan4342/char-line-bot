# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint(8)        not null, primary key
#  talk_type  :string
#  user_id    :string
#  masa       :boolean
#  linked     :boolean
#  user_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
end
