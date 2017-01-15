require 'rails_helper'

RSpec.describe Message, :type => :model do
  let(:message) { Message.new }


  it 'belongs to a conversation' do
    message.conversation = Conversation.new
    expect(message.conversation).to be_a(Conversation)
  end

  describe '.in_conversation' do
    before do
      message.update_attribute(:conversation_id, 1)
    end

    it 'returns the messages in a conversation' do
      expect(Message.in_conversation(1)).to eq([message])
    end

    it 'returns messages before the before_time' do
      time = Time.now
      Message.create(:conversation_id => 1, :created_at => time + 1)
      expect(Message.in_conversation(1, before_time: time)).to eq([message])
    end

    it 'returns latest message first' do
      message_2 = Message.new
      message_2.update_attribute(:conversation_id, 1)
      expect(Message.in_conversation(1)).to eq([message_2, message])
    end
  end

  describe '.all_in_conversation' do
    let(:message_2) { Message.new }
    before do
      message.update_attribute(:conversation_id, 1)
      message_2.update_attribute(:conversation_id, 1)
    end

    it 'returns all the messages in a conversation' do
      expect(Message.all_in_conversation(1)).to match_array([message, message_2])
    end

    it 'returns all the messages before the before_time' do
      time = Time.now
      message_3 = Message.create(:conversation_id => 1, :created_at => time + 1)
      expect(Message.all_in_conversation(1, before_time: time)).to_not include(message_3)
    end
  end
end
