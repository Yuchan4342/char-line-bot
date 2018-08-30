class CreateTalkGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :talk_groups do |t|
      t.string :group_id
      t.timestamps
    end
  end
end
