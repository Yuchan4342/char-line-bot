class RenameEventToWebhookEvent < ActiveRecord::Migration[5.2]
  def change
    rename_table :events, :webhook_events
  end
end
