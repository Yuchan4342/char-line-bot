class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|

      t.string :type
      t.integer :timestamp, :limit => 8 # bigint
      t.string :source_type
      t.integer :user_id, :limit => 8 # bigint
      t.integer :room_id, :limit => 8 # bigint
      t.integer :talk_group_id, :limit => 8 # bigint
      t.timestamps
    end
  end
end
