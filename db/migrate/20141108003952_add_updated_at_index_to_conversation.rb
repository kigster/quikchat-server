class AddUpdatedAtIndexToConversation < ActiveRecord::Migration
  def change
    #For sorting conversation for inbox and for getting unread conversation count
    add_index :conversations, :updated_at
  end
end
