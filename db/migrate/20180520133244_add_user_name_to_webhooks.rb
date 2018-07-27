class AddUserNameToWebhooks < ActiveRecord::Migration[5.1]
  def change
    add_column :webhooks, :user_name, :string
  end
end
