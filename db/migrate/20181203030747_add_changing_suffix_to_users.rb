class AddChangingSuffixToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :changing_suffix, :boolean, default: false
  end
end
