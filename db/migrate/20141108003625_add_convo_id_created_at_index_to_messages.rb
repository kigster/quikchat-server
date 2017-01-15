class AddConvoIdCreatedAtIndexToMessages < ActiveRecord::Migration
  def change
    #For getting paged messages in a conversation
    add_index :messages, [:conversation_id, :created_at]
  end
end
