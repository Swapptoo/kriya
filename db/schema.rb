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

ActiveRecord::Schema.define(version: 20161001081225) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.text     "html"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_attachments_on_message_id", using: :btree
  end

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["provider"], name: "index_authorizations_on_provider", using: :btree
    t.index ["uid"], name: "index_authorizations_on_uid", using: :btree
    t.index ["user_id"], name: "index_authorizations_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.string   "body"
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "likes_count", default: 0
    t.index ["post_id"], name: "index_comments_on_post_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "followable_type"
    t.integer  "followable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id", using: :btree
    t.index ["user_id"], name: "index_follows_on_user_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "goomps", force: :cascade do |t|
    t.string   "name"
    t.string   "cover"
    t.string   "slug"
    t.string   "description"
    t.integer  "memberships_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "logo"
    t.integer  "price_cents"
    t.string   "price_currency",    default: "USD", null: false
    t.float    "rating"
    t.integer  "reviews_count",     default: 0
    t.integer  "posts_count",       default: 0
    t.index ["slug"], name: "index_goomps_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_goomps_on_user_id", using: :btree
  end

  create_table "likes", force: :cascade do |t|
    t.string   "likable_type"
    t.integer  "likable_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["likable_type", "likable_id"], name: "index_likes_on_likable_type_and_likable_id", using: :btree
    t.index ["user_id"], name: "index_likes_on_user_id", using: :btree
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "goomp_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goomp_id", "user_id"], name: "index_memberships_on_goomp_id_and_user_id", unique: true, using: :btree
    t.index ["goomp_id"], name: "index_memberships_on_goomp_id", using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.string   "body"
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "image"
    t.integer  "post_id"
    t.boolean  "seen",       default: false
    t.index ["post_id"], name: "index_messages_on_post_id", using: :btree
    t.index ["room_id"], name: "index_messages_on_room_id", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payments_on_user_id", using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text     "body"
    t.integer  "comments_count"
    t.integer  "goomp_id"
    t.integer  "user_id"
    t.integer  "subtopic_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "title"
    t.integer  "likes_count",      default: 0
    t.string   "link_title"
    t.string   "link_url"
    t.string   "link_image"
    t.string   "link_description"
    t.text     "content"
    t.string   "link_video"
    t.index ["goomp_id"], name: "index_posts_on_goomp_id", using: :btree
    t.index ["subtopic_id"], name: "index_posts_on_subtopic_id", using: :btree
    t.index ["user_id"], name: "index_posts_on_user_id", using: :btree
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "goomp_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goomp_id"], name: "index_reviews_on_goomp_id", using: :btree
    t.index ["user_id"], name: "index_reviews_on_user_id", using: :btree
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "manager_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "category_name"
    t.integer  "budget_cents",    default: 0,     null: false
    t.string   "budget_currency", default: "USD", null: false
    t.string   "timeline"
    t.string   "quality"
    t.text     "description"
    t.index ["manager_id"], name: "index_rooms_on_manager_id", using: :btree
    t.index ["user_id"], name: "index_rooms_on_user_id", using: :btree
  end

  create_table "subtopics", force: :cascade do |t|
    t.string   "name"
    t.integer  "goomp_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goomp_id"], name: "index_subtopics_on_goomp_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "username"
    t.string   "bio"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "picture"
    t.string   "headline"
    t.string   "work_experience"
    t.string   "gender",                 default: "male"
    t.string   "avatar"
    t.string   "slug"
    t.string   "stipe_customer_id"
    t.integer  "follows_count",          default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "attachments", "messages"
  add_foreign_key "authorizations", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "follows", "users"
  add_foreign_key "goomps", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "memberships", "goomps"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "posts"
  add_foreign_key "messages", "rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "posts", "goomps"
  add_foreign_key "posts", "subtopics"
  add_foreign_key "posts", "users"
  add_foreign_key "reviews", "goomps"
  add_foreign_key "reviews", "users"
  add_foreign_key "rooms", "users"
  add_foreign_key "rooms", "users", column: "manager_id"
  add_foreign_key "subtopics", "goomps"
end
