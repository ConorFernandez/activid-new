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

ActiveRecord::Schema.define(version: 20150109184542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "poster_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commentable_id"
    t.string   "commentable_type"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree

  create_table "cuts", force: true do |t|
    t.integer  "project_id"
    t.integer  "uploader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
  end

  create_table "file_uploads", force: true do |t|
    t.string   "url"
    t.string   "attachable_type"
    t.string   "uuid"
    t.integer  "attachable_id"
    t.integer  "zencoder_job_id"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zencoder_status"
    t.string   "preview_url"
    t.string   "zencoder_error"
  end

  add_index "file_uploads", ["attachable_id", "attachable_type"], name: "index_file_uploads_on_attachable_id_and_attachable_type", using: :btree
  add_index "file_uploads", ["uuid"], name: "index_file_uploads_on_uuid", using: :btree

  create_table "projects", force: true do |t|
    t.integer  "user_id"
    t.integer  "price"
    t.string   "uuid"
    t.string   "name"
    t.string   "category"
    t.string   "desired_length"
    t.string   "turnaround"
    t.text     "instructions"
    t.boolean  "allow_to_be_featured", default: true
    t.boolean  "append_logo",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
    t.integer  "editor_id"
    t.text     "activid_music_urls"
    t.string   "stripe_card_id"
  end

  add_index "projects", ["editor_id"], name: "index_projects_on_editor_id", using: :btree
  add_index "projects", ["uuid"], name: "index_projects_on_uuid", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.string   "role",                   default: "user"
    t.string   "stripe_recipient_id"
    t.string   "bank_account_last_four"
    t.string   "stripe_customer_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
