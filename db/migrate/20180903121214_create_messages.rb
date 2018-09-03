class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :reply_token
      t.string :message_id
      t.string :type
      t.string :text
      t.integer :webhook_event_id, :limit => 8 # bigint
      t.timestamps
    end
  end
end
