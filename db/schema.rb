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

ActiveRecord::Schema.define(version: 20141120211244) do

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

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "desired_length"
    t.string   "uuid"
    t.text     "instructions"
    t.boolean  "allow_to_be_featured", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["uuid"], name: "index_projects_on_uuid", using: :btree

end
