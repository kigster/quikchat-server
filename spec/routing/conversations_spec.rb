require 'rails_helper'

RSpec.describe '/conversations' do
  describe 'POST to /conversations' do
    it 'routes to conversations#create' do
      expect(post: '/conversations').to route_to(controller: 'conversations', action: 'create')
    end
  end

  describe 'POST to /conversations/1/messages' do
    it 'routes to messages#create' do
      expect(post: '/conversations/1/messages').to route_to(controller: 'messages', action: 'create', conversation_id: "1")
    end
  end

  describe 'GET /conversations/1/messages' do
    it 'routes to messages#index' do
      expect(get: '/conversations/1/messages').to route_to(controller: 'messages', action: 'index', conversation_id: "1")
    end
  end
end
