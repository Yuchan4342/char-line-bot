class AddMasaToWebhooks < ActiveRecord::Migration[5.1]
  def change
    add_column :webhooks, :masa, :boolean
  end
end
