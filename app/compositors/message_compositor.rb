class MessageCompositor < Compositor::Leaf

  attr_accessor :message

  def initialize(context, message, attrs = {})
    super(context, attrs)
    self.message = message
  end

  def to_hash
    with_root_element do
      h = {
        id: message.id,
        conversation_id: message.conversation_id,
        user_id: message.user_id,
        body: message.body,
        subject_type: message.subject_type,
        subject_id: message.subject_id,
        created_at: message.created_at,
      }

      h
    end
  end
end
