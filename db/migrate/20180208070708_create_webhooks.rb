# CreateWebhooks
class CreateWebhooks < ActiveRecord::Migration[5.1]
  def change
    create_table :webhooks do |t|
      t.string :type
      t.string :user_id

      t.timestamps
    end
  end
end
