class DropLastUserIdFromConversation < ActiveRecord::Migration
  def up
    remove_column :conversations, :last_user_id
  end

  def down
    add_column :conversations, :last_user_id, :datetime
  end
end
