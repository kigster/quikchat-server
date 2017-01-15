require 'rails_helper'

RSpec.describe ConversationCompositor do
  let(:conversation) { Conversation.find_or_create_by_user_ids(1, 2)}
  let!(:last_message) { conversation.create_message(user_id: 1, body: 'text') }

  describe 'to_hash' do
    it 'returns a hash with id, participants, last_messages and updated_at' do
      result = ConversationCompositor.new(nil, conversation).to_hash

      expect(result[:id]).to eql(conversation.id)
      expect(result[:last_message][:id]).to eql(conversation.last_message.id)
      expect(result[:updated_at]).to eql(conversation.updated_at)

      participant_ids = result[:participants].map{|p| p[:id]}
      expect(participant_ids).to include(1, 2)
    end
  end

end
