require 'rails_helper'

RSpec.describe Participant, :type => :model do
  let(:participant) { Participant.new }

  it 'belongs to a conversation' do
    participant.conversation = Conversation.new
    expect(participant.conversation).to be_a(Conversation)
  end
end
