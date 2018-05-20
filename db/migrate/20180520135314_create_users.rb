class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :talk_type
      t.string :user_id
      t.boolean :masa
      t.boolean :linked
      t.string :user_name

      t.timestamps
    end
  end
end
