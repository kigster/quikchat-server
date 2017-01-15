require 'rails_helper'

RSpec.describe MessagesController do
  let(:conversation) { Conversation.find_or_create_by_user_ids(1,2)}
  describe "#create" do
    it "adds a message to the conversation" do
      message_params = {"user_id" => "2", "body" => "hiii", "subject_type" => "Product", "subject_id" => "3"}
      expect(conversation).to receive(:create_message).with(message_params)
      expect(Conversation).to receive(:find_by_id).with(conversation.id).and_return(conversation)

      post :create, conversation_id: conversation.id, message: message_params, user_id: 1
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json['conversations'].first['id']).to eq(conversation.id)
    end

    it 'return not authorized if user is not in the conversation' do
      conversation = Conversation.find_or_create_by_user_ids(1,2)
      post :create, conversation_id: conversation.id, user_id: 3, body: "hii"
      expect(response.status).to eq(401)
    end

    it "raises NotFoundError when a conversation does not exist" do
      post :create, conversation_id: 1, user_id: 2, body: "hii"
      expect(response.status).to eq 404
    end
  end

  describe "#index" do
    let(:message) { double(Message, created_at: Time.now, as_json: {id: 1}) }

    before do
      allow_any_instance_of(MessageCompositor).to receive(:to_hash).and_return({id: 1})
    end

    it "returns the newest messages in a conversation, earlier message count and unread conversation count" do
      expect(Message).to receive(:in_conversation).with(conversation.id, before_time: nil).and_return([message])
      expect(Message).to receive(:all_in_conversation).with(conversation.id, before_time: message.created_at).and_return([message, message, message])
      expect(Conversation).to receive(:unread_count_for_user_id).with(1).and_return(2)
      expect(Conversation).to receive(:find_by_id).and_return(conversation)
      expect(conversation).to receive(:mark_read!).with(1)

      get :index, conversation_id: conversation.id, user_id: 1
      json = JSON.parse(response.body)
      expect(json["messages"]).to eq([{"id" => 1}])
      expect(json["earlier_message_count"]).to eq(3)
      expect(json["unread_conversation_count"]).to eq(2)
    end

    it "returns the messages in a conversation before the before_id" do
      iso_time = Time.now.iso8601
      expect(Message).to receive(:in_conversation).with(conversation.id, before_time: Time.parse(iso_time)).and_return([message])
      expect(Conversation).to receive(:find_by_id).and_return(conversation)
      expect(conversation).not_to receive(:mark_read!).with(1)

      get :index, conversation_id: conversation.id, before_time: iso_time, user_id: 1
      json = JSON.parse(response.body)
      expect(json["messages"]).to eq([{"id" => 1}])
      expect(json["earlier_message_count"]).to eq(0)
    end

    it "returns success if there are no messages" do
      expect(Message).to receive(:in_conversation).with(conversation.id, before_time: nil).and_return([])

      get :index, conversation_id: conversation.id, user_id: 1
      expect(response.status).to eq(200)

      json = JSON.parse(response.body)
      expect(json["messages"]).to eq([])
      expect(json["earlier_message_count"]).to eq(0)
    end

    it 'return not authorized if user is not in the conversation' do
      get :index, conversation_id: conversation.id, user_id: 3
      expect(response.status).to eq(401)
    end
  end
end
