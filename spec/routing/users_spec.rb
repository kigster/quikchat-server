require 'rails_helper'

RSpec.describe '/users' do
  describe 'GET /users/1/conversations' do
    it 'routes to users#conversations' do
      expect(get: '/users/1/conversations').
          to route_to(controller: 'conversations', action: 'index', user_id: '1')
    end
  end

  describe 'GET /users/1/unread_conversation_count' do
    it 'routes to conversations#unread_count' do
      expect(get: '/users/1/unread_conversation_count').to route_to(controller: 'conversations', action: 'unread_count', user_id: '1')
    end
  end
end
