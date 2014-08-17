class CreateTicketingTables < ActiveRecord::Migration
  def change
    create_table "crm_case_details", force: true do |t|
      t.integer  "case_id",    null: false
      t.integer  "sort",       null: false
      t.string   "key",        null: false
      t.text     "value",      null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "crm_queues", force: true do |t|
      t.string   "name",               null: false
      t.string   "notify_email"
      t.integer  "initial_assignment"
      t.string   "reply_name",         null: false
      t.string   "reply_email",        null: false
      t.text     "reply_signature"
      t.text     "web_instruction"
      t.text     "web_confirmation"
      t.boolean  "pop3_enabled",       null: false
      t.string   "pop3_login"
      t.string   "pop3_password"
      t.boolean  "pop3_use_ssl"
      t.string   "pop3_error"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "pop3_host"
    end

    create_table "crm_case_updates", force: true do |t|
      t.integer  "case_id"
      t.integer  "user_id",      null: false
      t.text     "response",     null: false
      t.binary   "data"
      t.text     "private_note"
      t.boolean  "state_update", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "crm_case_updates", ["case_id"], name: "index_case_updates_on_case_id", using: :btree

    create_table "crm_cases", force: true do |t|
      t.integer  "case_queue_id", null: false
      t.string   "priority",      null: false
      t.string   "status",        null: false
      t.integer  "assigned_to"
      t.integer  "user_id"
      t.string   "name",          null: false
      t.string   "email"
      t.string   "phone"
      t.string   "subject",       null: false
      t.text     "description"
      t.string   "received_via",  null: false
      t.text     "form_data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "crm_cases", ["case_queue_id"], name: "index_cases_on_case_queue_id", using: :btree
  end
end
