class ConversationCompositor < Compositor::Leaf

  attr_accessor :conversation

  def initialize(context, conversation, attrs = {})
    super(context, attrs)
    self.conversation = conversation
  end

  def to_hash
    with_root_element do
      {
        id: conversation.id,
        last_message: conversation.last_message.nil? ? nil : MessageCompositor.new(context, conversation.last_message).to_hash,
        participants: participants,
        updated_at: conversation.updated_at
      }
    end
  end

  def participants
    conversation.participants.map do |participant|
      ts = participant.last_read_at && participant.last_read_at.utc.iso8601
      {id: participant.user_id, last_read_at: ts}
    end
  end
end
