class RemoveMasaFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :masa
  end
end
