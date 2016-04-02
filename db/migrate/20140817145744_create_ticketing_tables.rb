class CreateTicketingTables < ActiveRecord::Migration
  def change
    
    create_table "crm_case_details", force: :cascade do |t|
      t.integer  "case_id",    limit: 4,     null: false
      t.integer  "sort",       limit: 4,     null: false
      t.string   "key",        limit: 255,   null: false
      t.text     "value",      limit: 65535, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "crm_case_updates", force: :cascade do |t|
      t.integer  "case_id",      limit: 4
      t.datetime "received_at",                                  null: false
      t.integer  "user_id",      limit: 4
      t.text     "response",     limit: 65535,                   null: false
      t.string   "attachments",  limit: 255
      t.text     "raw_data",     limit: 4294967295
      t.text     "private_note", limit: 65535
      t.string   "new_state",    limit: 32,         default: ""
      t.string   "new_priority", limit: 32
      t.integer  "new_assignee", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "crm_case_updates", ["case_id"], name: "index_case_updates_on_case_id", using: :btree

    create_table "crm_cases", force: :cascade do |t|
      t.integer  "case_queue_id", limit: 4,                        null: false
      t.datetime "received_at",                                    null: false
      t.string   "priority",      limit: 255,                      null: false
      t.string   "status",        limit: 255,                      null: false
      t.integer  "assigned_to",   limit: 4
      t.string   "attachments",   limit: 255,        default: "0", null: false
      t.integer  "user_id",       limit: 4
      t.string   "name",          limit: 255,                      null: false
      t.string   "email",         limit: 255
      t.string   "phone",         limit: 255
      t.string   "subject",       limit: 255,                      null: false
      t.text     "description",   limit: 65535
      t.string   "received_via",  limit: 255,                      null: false
      t.text     "raw_data",      limit: 4294967295
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "crm_cases", ["case_queue_id"], name: "index_cases_on_case_queue_id", using: :btree

    create_table "crm_queues", force: :cascade do |t|
      t.string   "name",               limit: 255,                 null: false
      t.string   "notify_email",       limit: 255
      t.integer  "initial_assignment", limit: 4
      t.string   "reply_name",         limit: 255,                 null: false
      t.string   "reply_email",        limit: 255,                 null: false
      t.text     "reply_signature",    limit: 65535
      t.text     "web_instruction",    limit: 65535
      t.text     "web_confirmation",   limit: 65535
      t.boolean  "pop3_enabled",                                   null: false
      t.string   "pop3_login",         limit: 255
      t.string   "pop3_password",      limit: 255
      t.boolean  "pop3_use_ssl"
      t.string   "pop3_error",         limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "pop3_host",          limit: 255
      t.integer  "pop3_port",          limit: 4,     default: 110, null: false
    end
    
  end
end
