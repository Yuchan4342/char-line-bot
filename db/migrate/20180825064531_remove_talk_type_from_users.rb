class RemoveTalkTypeFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :talk_type
  end
end
