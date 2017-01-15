require 'rails_helper'

RSpec.describe Conversation do
  let(:conversation) { Conversation.find_or_create_by_user_ids(1,2) }

  describe '.with_user_id' do
    it 'returns conversations that a user participates in' do
      expect(conversation).to be_persisted
      c = Conversation.with_user_id(1).first
      expect(c).to eq(conversation)
      expect(c.participants.map(&:user_id)).to eq([1,2])
    end
  end

  describe '.find_last_posted_in_by_user_id' do
    it 'returns the conversation that a user last posted in' do
      other = Conversation.find_or_create_by_user_ids(1,2,3)

      Message.create!(conversation: conversation, user_id: 1, body: 'hello')
      expect(Conversation.find_last_posted_in_by_user_id(1)).to eq(conversation)

      Message.create!(conversation: other, user_id: 1, body: 'new message')
      expect(Conversation.find_last_posted_in_by_user_id(1)).to eq(other)

      Message.create!(conversation: conversation, user_id: 2, body: 'rogue hacker guy')
      expect(Conversation.find_last_posted_in_by_user_id(1)).to eq(other)
    end
  end

  describe '.find_or_create_by_user_ids' do
    it 'creates new conversations and finds existing ones' do
      expect {
        cid = Conversation.find_or_create_by_user_ids([1, 2]).id
        expect(Conversation.find_or_create_by_user_ids([1, 2]).id).to eq(cid)
      }.to change { Conversation.count }.by(1)
    end
  end

  describe '#user_ids' do
    it 'returns an array of the participant ids' do
      expect(conversation.user_ids).to eq([1, 2])
    end
  end

  describe '#last_message' do
    it 'returns the last message posted to the conversation' do
      message = conversation.create_message(user_id: 1, body: 'hello')
      expect(conversation.last_message).to eq(message)
    end
  end

  describe '#mark_read!' do
    it 'updates the participant last_read_at' do
      participant = conversation.participants.first
      expect {
        conversation.mark_read!(participant.user_id)
      }.to change{ participant.reload.last_read_at }
    end
  end

  describe '#find_by_id_and_user_id' do
    context 'user is a participant' do
      let(:user_id) { 1 }

      it 'returns conversation with given id' do
        expect(Conversation.find_by_id_and_user_id(conversation.id, user_id)).to eq(conversation)
      end
    end

    context 'user is a participant' do
      let(:user_id) { 4 }

      it 'returns nil if the given user_id is not a participant' do
        expect(Conversation.find_by_id_and_user_id(conversation.id, user_id)).to be_nil
      end
    end
  end

  describe '#self.active_for_user_id' do
    it 'returns active conversation' do
      conversation.participants.each {|p| p.update_attribute(:active, true)}
      expect(Conversation.active_for_user_id(1)).to eq(conversation)
      expect(Conversation.active_for_user_id(2)).to eq(conversation)
    end

    it 'returns last updated conversation if there are no conversations marked as active' do
      c2 = Conversation.find_or_create_by_user_ids(2,3)
      expect(Conversation.active_for_user_id(2)).to eq(c2)
    end
  end

  describe '#create_message' do
    it 'marks conversation as active' do
      expect(Conversation.active_for_user_id(1)).to_not eq(conversation)
      conversation.create_message(user_id: 1, body: 'hello')
      expect(Conversation.active_for_user_id(1)).to eq(conversation)
    end

    it 'updates last_read_at of participant' do
      Timecop.freeze Time.now do
        conversation.create_message(user_id: 1, body: 'hello')
        expect(conversation.participants.find_by_user_id(1).last_read_at.to_i).to eq(Time.now.to_i)
      end
    end
  end

  describe '#page_for_user_id' do
    it 'returns conversation ordered by updated_at' do
      time = Time.now
      (1..20).each do |i|
        Timecop.freeze(time + i.days) do
          Conversation.find_or_create_by_user_ids(1,i+1)
        end
      end

      first_page = Conversation.page_for_user_id(1)
      expect(first_page.first).to eql(Conversation.find_or_create_by_user_ids(1, 21))
    end

    it 'returns requested page' do
      stub_const("Conversation::PER_PAGE", 1)
      time = Time.now
      Timecop.freeze(time - 1.days) do
        Conversation.find_or_create_by_user_ids(1, 2)
      end
      Timecop.freeze(time - 2.days) do
        Conversation.find_or_create_by_user_ids(1, 3)
      end

      second_page = Conversation.page_for_user_id(1, page: 2)
      expect(second_page.first).to eql(Conversation.find_or_create_by_user_ids(1, 3))
    end
  end

  describe '#unread_count_for_user_id' do
    it 'returns unread conversations count' do
      conversation.create_message(user_id: 2, body: 'hello')
      expect(Conversation.unread_count_for_user_id(1)).to eq 1

      conversation.mark_read!(1)
      expect(Conversation.unread_count_for_user_id(1)).to eq 0
    end
  end
end
