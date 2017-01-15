(1..10).each do |i|
  Conversation.find_or_create_by_user_ids(i, i+1)
end
