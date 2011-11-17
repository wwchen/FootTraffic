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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111117205138) do

  create_table "checkins", :force => true do |t|
    t.string   "user_id"
    t.string   "tweet_id"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "created"
    t.boolean  "processed"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "locations", :force => true do |t|
    t.string   "twitter_id"
    t.string   "name"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "daily",        :limit => 255
    t.text     "weekly",       :limit => 255
    t.text     "annually",     :limit => 255
    t.string   "bounding_box"
    t.string   "place_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
