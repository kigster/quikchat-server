require "rails_helper"

RSpec.describe "when a ruby-web user sends and receives messages" do
  let(:alice_id) { 1 }
  let(:bob_id) { 2 }

  it "stores and returns those messages" do
    get "/users/#{alice_id}/conversations"
    expect(response_json['conversations']).to eq([])

    post "/conversations", user_ids: [alice_id, bob_id]
    expect(response_json).to include("conversations")
    expect(response_json["conversations"][0]).to include("participants" => [
      {'id' => alice_id, 'last_read_at' => nil},
      {'id' => bob_id, 'last_read_at' => nil}
    ])
    conversation_id = response_json["conversations"][0]["id"]

    get "/users/#{alice_id}/conversations"
    expect(response_json).to include("conversations")
    expect(response_json["conversations"].first).to include("id" => conversation_id)

    post "/conversations/#{conversation_id}/messages?user_id=#{alice_id}", message: {
      user_id: alice_id,
      body: "hi bob",
      subject_type: "Product",
      subject_id: "100"
    }
    expect(response).to be_success

    get "/conversations/#{conversation_id}/messages?user_id=#{alice_id}"
    message_json = response_json["messages"].first
    expect(message_json).to include(
      "body" => "hi bob",
      "subject_type" => "Product",
      "subject_id" => 100
    )

    post "/conversations/#{conversation_id}/messages?user_id=#{bob_id}", message: {
      user_id: bob_id,
      body: "hello yourself"
    }
    expect(response).to be_success
    new_message = response_json["conversations"].first["last_message"]

    get "/conversations/#{conversation_id}/messages?before_time=#{new_message["created_at"]}&user_id=#{alice_id}"
    expect(response_json["messages"]).to eq([message_json])

    get "/users/#{alice_id}/conversations"
    expect(response_json["conversations"].first["last_message"]).to include("id" => new_message["id"])

    time = Time.now
    Timecop.freeze time do
      post "/conversations/#{conversation_id}/mark_as_read", user_id: alice_id
      get "/users/#{alice_id}/conversations"
      expect(response_json["conversations"].first["participants"]).to include("id" => alice_id, "last_read_at" => time.utc.iso8601)
    end

  end

  def response_json
    JSON.parse(response.body)
  end
end
