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

ActiveRecord::Schema.define(version: 20141126220223) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "file_uploads", force: true do |t|
    t.string   "url"
    t.string   "attachable_type"
    t.string   "uuid"
    t.integer  "attachable_id"
    t.integer  "zencoder_job_id"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_uploads", ["attachable_id", "attachable_type"], name: "index_file_uploads_on_attachable_id_and_attachable_type", using: :btree
  add_index "file_uploads", ["uuid"], name: "index_file_uploads_on_uuid", using: :btree

  create_table "payment_methods", force: true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.integer  "user_id"
    t.integer  "payment_method_id"
    t.string   "uuid"
    t.string   "name"
    t.string   "category"
    t.string   "desired_length"
    t.string   "turnaround"
    t.text     "instructions"
    t.boolean  "allow_to_be_featured", default: true
    t.boolean  "watermark",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["uuid"], name: "index_projects_on_uuid", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
