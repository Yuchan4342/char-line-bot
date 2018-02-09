class RenameTitleColumnToWebhooks < ActiveRecord::Migration[5.1]
  def change
  	rename_column :webhooks, :type, :talk_type
  end
end
