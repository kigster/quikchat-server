require 'rails_helper'

RSpec.describe MessageCompositor do
  let!(:message) { Conversation.find_or_create_by_user_ids(1, 2).create_message(user_id: 1, body: 'text', subject_type: 'Product', subject_id: '102') }

  describe 'to_hash' do
    it 'returns a hash with message properties' do
      result = MessageCompositor.new(nil, message).to_hash

      expect(result[:id]).to eql(message.id)
      expect(result[:created_at]).to eql(message.created_at)
      expect(result[:conversation_id]).to eql(message.conversation.id)
      expect(result[:user_id]).to eql(message.user_id)
      expect(result[:body]).to eql(message.body)
      expect(result[:subject_type]).to eql(message.subject_type)
      expect(result[:subject_id]).to eql(message.subject_id)
      expect(result[:created_at]).to eql(message.created_at)
    end
  end

end
