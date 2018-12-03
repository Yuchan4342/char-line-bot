class RemoveLinkedFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :linked
  end
end
