class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :conversation_id
      t.integer :user_id
      t.text    :body
      t.string  :subject_type
      t.integer :subject_id

      t.timestamps
    end
  end
end
