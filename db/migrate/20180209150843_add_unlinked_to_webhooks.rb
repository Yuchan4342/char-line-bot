class AddUnlinkedToWebhooks < ActiveRecord::Migration[5.1]
  def change
    add_column :webhooks, :unlinked, :boolean
  end
end
