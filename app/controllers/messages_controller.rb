require 'new_relic/agent/method_tracer'

class MessagesController < ApplicationController
  extend ::NewRelic::Agent::MethodTracer

  before_filter :set_conversation!
  before_filter :authorize_user!

  def create
    conversation.create_message(message_params)
    c = Compositor::DSL.create(view_context) do
      map do
        list collection: [@conversation], root: :conversations do |c|
          conversation c
        end
      end
    end
    render json: c.to_hash
  end

  def index
    conversation.mark_read!(user_id) unless before_time #update only for the first page
    @messages = Message.in_conversation(conversation.id, before_time: before_time)
    @unread_count = Conversation.unread_count_for_user_id(user_id)
    @earlier_message_count = @messages.empty? ? 0 : Message.all_in_conversation(conversation.id, before_time: @messages.last.created_at).count
    self.class.trace_execution_scoped(['Messages/index/render']) do
      c = Compositor::DSL.create(view_context) do
        map do
          list collection: @messages, root: :messages do |m|
            message m
          end
          literal(unread_conversation_count: @unread_count)
          literal(earlier_message_count: @earlier_message_count)
        end
      end
      render json: c.to_hash
    end
  end

  def index_f
    html = Flamegraph.generate do
      conversation.mark_read!(user_id) unless before_time #update only for the first page
      @messages = Message.in_conversation(conversation.id, before_time: before_time)
      @unread_count = Conversation.unread_count_for_user_id(user_id)
      @earlier_message_count = messages.empty? ? 0 : Message.all_in_conversation(conversation.id, before_time: messages.last.created_at).count
      self.class.trace_execution_scoped(['Messages/index/render']) do
        c = Compositor::DSL.create(view_context) do
          map do
            list collection: @messages, root: :messages do |m|
              message m
            end
            literal(unread_conversation_count: @unread_count)
            literal(earlier_message_count: @earlier_message_count)
          end
        end
        c.to_hash.to_json
      end
    end
    render text: html
  end

protected

  def authorize_user!
    head :unauthorized unless conversation.user_ids.include? user_id
  end

  def user_id
    params.require(:user_id).to_i
  end

  def set_conversation!
    head :not_found unless conversation
  end

  def conversation
    @conversation ||= DatabaseHelper.failover_on :blank? do
      Conversation.find_by_id(params.require(:conversation_id).to_i)
    end
  end

  def message_params
    params.require(:message).permit(:user_id, :body, :subject_type, :subject_id)
  end

  def before_time
    params[:before_time] ? Time.parse(params[:before_time]) : nil
  end

end
