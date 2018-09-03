class ChangeColumnWebhookEventIdNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :messages, :webhook_event_id, :bigint, null: false
  end
end
