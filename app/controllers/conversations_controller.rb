require 'new_relic/agent/method_tracer'

class ConversationsController < ApplicationController
  extend ::NewRelic::Agent::MethodTracer

  before_filter :set_conversation!, only: [:mark_as_read]
  before_filter :authorize_user!, only: [:mark_as_read]

  def index
    @conversations = Conversation.page_for_user_id(user_id, page: page).to_a
    @next_page = next_page_for(@conversations, page, Conversation::PER_PAGE)
    self.class.trace_execution_scoped(['Conversations/index/render']) do
      c = Compositor::DSL.create(view_context) do
        map do
          list collection: @conversations, root: :conversations do |c|
            conversation c
          end
          literal(next_page: @next_page)
        end
      end
      render json: c.to_hash
    end
  end

  def index_f
    html = Flamegraph.generate do
      @conversations = Conversation.page_for_user_id(user_id, page: page).to_a
      @next_page = next_page_for(@conversations, page, Conversation::PER_PAGE)
      self.class.trace_execution_scoped(['Conversations/index/render']) do
        c = Compositor::DSL.create(view_context) do
          map do
            list collection: @conversations, root: :conversations do |c|
              conversation c
            end
            literal(next_page: @next_page)
          end
        end
        c.to_hash.to_json
      end
    end

    render text: html
  end

  def create
    @created = Conversation.find_or_create_by_user_ids(user_ids)
    c = Compositor::DSL.create(view_context) do
      map do
        list collection: [@created], root: :conversations do |c|
          conversation c
        end
      end
    end
    render json: c.to_hash
  end

  def show
    @conversation = Conversation.find_by_id_and_user_id(params[:id], user_id)
    c = Compositor::DSL.create(view_context) do
      map do
        conversation @conversation, root: :conversation
      end
    end
    render json: c.to_hash
  end

  def active
    active = Conversation.active_for_user_id(user_id)
    @conversations = []
    @conversations << active if active
    c = Compositor::DSL.create(view_context) do
      map do
        list collection: @conversations, root: :conversations do |c|
          conversation c
        end
      end
    end
    render json: c.to_hash
  end

  def unread_count
    unread_count = Conversation.unread_count_for_user_id(user_id)
    render json: {unread_count: unread_count}
  end

  def unread_count_f
    html = Flamegraph.generate do
      unread_count = Conversation.unread_count_for_user_id(user_id)
      {unread_count: unread_count}.to_json
    end
    render text: html
  end

  def mark_as_read
    conversation = Conversation.find(params.require(:id))
    conversation.mark_read!(user_id)
    head :ok
  end

protected

  def set_conversation!
    head :not_found unless conversation
  end

  def conversation
    @conversation ||= DatabaseHelper.failover_on :blank? do
      Conversation.find_by_id(conversation_id)
    end
  end

  def conversation_id
    params.require(:id).to_i
  end

  def user_id
    params.require(:user_id).to_i
  end

  def user_ids
    if params.require(:user_ids).is_a?(Array)
      params[:user_ids].map(&:to_i)
    else
      raise ActiveRecord::RecordInvalid, "Conversations require user IDs"
    end
  end

  def page
    params[:page] ? params[:page].to_i : 1
  end

  def participant_params
    params.require(:conversation).require(:participants)
  end

  def authorize_user!
    head :unauthorized unless conversation.user_ids.include? user_id
  end

  def next_page_for(collection, page, per_page)
    !collection.blank? && collection.count == per_page ? page + 1 : nil
  end

end
