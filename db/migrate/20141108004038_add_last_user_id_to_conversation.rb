class AddLastUserIdToConversation < ActiveRecord::Migration
  def change
    #For calculating unread conversation count with a single query
    add_column :conversations, :last_user_id, :integer
  end
end
