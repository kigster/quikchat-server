Rails.application.routes.draw do
  get   '/status_check' => 'status#check'

  get   '/users/:user_id/conversations/(:page)' => 'conversations#index', as: :conversations
  get   '/users/:user_id/conversations_f/(:page)' => 'conversations#index_f', as: :conversations_f
  get   '/users/:user_id/active_conversation' => 'conversations#active'
  get   '/users/:user_id/unread_conversation_count' => 'conversations#unread_count'
  get   '/users/:user_id/unread_conversation_count_f' => 'conversations#unread_count_f'
  post  '/conversations' => 'conversations#create'
  get   '/conversations/:id' => 'conversations#show'
  post '/conversations/:id/mark_as_read' => 'conversations#mark_as_read'

  get   '/conversations/:conversation_id/messages' => 'messages#index'
  get   '/conversations/:conversation_id/messages_f' => 'messages#index_f'
  post  '/conversations/:conversation_id/messages' => 'messages#create'
end
