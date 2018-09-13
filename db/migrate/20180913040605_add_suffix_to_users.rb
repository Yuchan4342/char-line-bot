class AddSuffixToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :suffix, :string
  end
end
