class AddConversationIdIndexToParticipants < ActiveRecord::Migration
  def change
    #For getting all participants in a conversation
    add_index :participants, :conversation_id
  end
end
