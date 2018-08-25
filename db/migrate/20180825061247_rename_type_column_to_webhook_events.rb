class RenameTypeColumnToWebhookEvents < ActiveRecord::Migration[5.2]
  def change
    rename_column :webhook_events, :type, :event_type
  end
end
