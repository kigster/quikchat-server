class AddConversationLastMessageId < ActiveRecord::Migration
  def change
    add_column :conversations, :last_message_id, :integer
  end
end
