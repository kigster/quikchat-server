class Message < ActiveRecord::Base
  belongs_to :conversation

  scope :in_conversation, -> (cid, before_time: nil) {
    all_in_conversation(cid, before_time: before_time).limit(20)
  }

  scope :all_in_conversation, -> (cid, before_time: nil) {
      where(conversation_id: cid).before_time(before_time).order("created_at desc")
    }

  scope :before_time, -> (before_time) {
    before_time ? where("created_at < ?", before_time) : nil
  }

  class << self
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :in_conversation, 'Message/in_conversation'
  end

end
