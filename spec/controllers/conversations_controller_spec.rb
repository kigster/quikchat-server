require 'rails_helper'

RSpec.describe ConversationsController do
  let(:conversation) { Conversation.find_or_create_by_user_ids([1, 2]) }

  describe "#index" do
    it "returns the conversations that belong to a user" do
      expect(Conversation).to receive(:page_for_user_id).with(1, page: 1).and_return([conversation])
      get :index, user_id: 1
      json = JSON.parse(response.body)

      expect(json['conversations'].first['id']).to eq(conversation.id)
    end

    it "respects the page parameter" do
      expect(Conversation).to receive(:page_for_user_id).with(1, page: 2).and_return([conversation])
      get :index, user_id: 1, page: 2
      json = JSON.parse(response.body)

      expect(json['conversations'].first['id']).to eq(conversation.id)
    end

    it "returns next_page information" do
      expect(Conversation).to receive(:page_for_user_id).with(1, page: 2).and_return([conversation])
      stub_const("Conversation::PER_PAGE", 1)
      get :index, user_id: 1, page: 2
      json = JSON.parse(response.body)

      expect(json['next_page']).to eq(3)
    end
  end

  describe "#create" do
    it 'tries to create the conversation and then renders the conversation' do
      expect(Conversation).to receive(:find_or_create_by_user_ids).
        with([1, 2]).and_return(conversation)

      post :create, user_ids: [1, 2]
      json = JSON.parse(response.body)

      expect(json['conversations'].first['id']).to eq(conversation.id)
    end
  end

  describe "#active" do
    it "returns the active conversation" do
      expect(Conversation).to receive(:active_for_user_id).with(1).
        and_return(conversation)
      get :active, user_id: 1
      json = JSON.parse(response.body)

      expect(json['conversations'].first['id']).to eq(conversation.id)
    end

    context "when there are no active conversations" do

      before do
        expect(Conversation).to receive(:active_for_user_id).with(1).and_return(nil)
      end
      it "returns empty array" do
        get :active, user_id: 1
        json = JSON.parse(response.body)

        expect(json['conversations']).to be_empty
      end
    end
  end

  describe "#show" do
    it "returns the conversation with given id and user id" do
      get :show, id: conversation.id, user_id: 1
      json = JSON.parse(response.body)

      expect(json['conversation']['id']).to eq(conversation.id)
    end
  end

  describe "#unread_count" do
    it "returns unread conversation count for given user id" do
      expect(Conversation).to receive(:unread_count_for_user_id).with(1).and_return(2)
      get :unread_count, user_id: 1
      json = JSON.parse(response.body)

      expect(json['unread_count']).to eq(2)
    end
  end
end
