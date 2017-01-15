# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141111003730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: true do |t|
    t.string   "user_ids_hash",   limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_message_id"
  end

  add_index "conversations", ["updated_at"], name: "index_conversations_on_updated_at", using: :btree
  add_index "conversations", ["user_ids_hash"], name: "index_conversations_on_user_ids_hash", unique: true, using: :btree

  create_table "messages", force: true do |t|
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.text     "body"
    t.string   "subject_type"
    t.integer  "subject_id"
    t.datetime "created_at"
  end

  add_index "messages", ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at", using: :btree

  create_table "participants", force: true do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.boolean  "notify",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_read_at"
    t.boolean  "active",          default: false
  end

  add_index "participants", ["conversation_id"], name: "index_participants_on_conversation_id", using: :btree
  add_index "participants", ["user_id", "conversation_id"], name: "index_participants_on_user_id_and_conversation_id", unique: true, using: :btree

end
