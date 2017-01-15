class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :user_ids_hash, :limit => 32, :nullable => false
      t.timestamps

      t.index :user_ids_hash, :unique => true
    end
  end
end
