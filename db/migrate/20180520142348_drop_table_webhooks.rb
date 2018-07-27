# DropTableWebhooks
class DropTableWebhooks < ActiveRecord::Migration[5.1]
  def change
    drop_table :webhooks
  end
end
