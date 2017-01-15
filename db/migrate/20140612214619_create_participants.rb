class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.integer :user_id
      t.integer :conversation_id
      t.boolean :notify, :default => true, :nullable => false
      t.timestamp :last_read_at
      t.timestamps

      t.index [:user_id, :conversation_id], :unique => true
    end
  end
end
