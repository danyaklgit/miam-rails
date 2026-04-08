# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_08_224908) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: ""
    t.text "featured_image_url", default: ""
    t.text "image_url", default: ""
    t.uuid "menu_id", null: false
    t.string "name", limit: 255, null: false
    t.uuid "restaurant_id", null: false
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_categories_on_menu_id"
    t.index ["restaurant_id"], name: "index_categories_on_restaurant_id"
  end

  create_table "customer_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city", limit: 100, null: false
    t.string "country", limit: 10, default: "BE"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "instructions", default: ""
    t.boolean "is_default", default: false
    t.string "label", limit: 100, default: ""
    t.string "postal_code", limit: 20, null: false
    t.uuid "restaurant_id"
    t.string "street", limit: 255, null: false
    t.string "user_id", limit: 128, null: false
    t.index ["restaurant_id"], name: "index_customer_addresses_on_restaurant_id"
    t.index ["user_id"], name: "index_customer_addresses_on_user_id"
  end

  create_table "dining_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "closed_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "order_id"
    t.uuid "restaurant_id", null: false
    t.uuid "restaurant_table_id", null: false
    t.string "status", limit: 20, default: "active"
    t.index ["restaurant_id", "restaurant_table_id", "status"], name: "idx_sessions_restaurant_table_status"
    t.index ["restaurant_id"], name: "index_dining_sessions_on_restaurant_id"
    t.index ["restaurant_table_id"], name: "index_dining_sessions_on_restaurant_table_id"
  end

  create_table "menu_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "allergens", default: []
    t.boolean "available", default: true
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description", default: ""
    t.jsonb "images", default: []
    t.uuid "menu_id", null: false
    t.string "name", limit: 255, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.uuid "restaurant_id", null: false
    t.integer "sort_order", default: 0
    t.jsonb "tags", default: []
    t.string "type", limit: 10, default: "food", null: false
    t.datetime "updated_at", null: false
    t.jsonb "variants", default: []
    t.index ["category_id"], name: "index_menu_items_on_category_id"
    t.index ["menu_id"], name: "index_menu_items_on_menu_id"
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "menus", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: ""
    t.boolean "is_active", default: true
    t.string "name", limit: 255, null: false
    t.uuid "restaurant_id", null: false
    t.jsonb "schedule", default: {"days"=>[], "type"=>"always", "endTime"=>"", "startTime"=>""}
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menus_on_restaurant_id"
  end

  create_table "offers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "applies_to", default: {"items"=>[], "categories"=>[], "wholeOrder"=>false}
    t.datetime "created_at", null: false
    t.integer "current_redemptions", default: 0
    t.integer "max_redemptions"
    t.decimal "min_order_amount", precision: 10, scale: 2
    t.string "name", limit: 255, null: false
    t.jsonb "order_types", default: ["dineIn", "takeaway", "delivery"]
    t.string "promo_code", limit: 50
    t.uuid "restaurant_id", null: false
    t.jsonb "schedule"
    t.string "type", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.index ["restaurant_id"], name: "index_offers_on_restaurant_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "claimed_by", limit: 128
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "menu_item_id"
    t.string "name", limit: 255, null: false
    t.text "notes", default: ""
    t.uuid "order_id", null: false
    t.string "ordered_by", limit: 128, null: false
    t.string "paid_by", limit: 128
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "quantity", default: 1
    t.string "status", limit: 20, default: "ordered"
    t.string "type", limit: 10, default: "food", null: false
    t.string "variant_id", limit: 100
    t.string "variant_name", limit: 255
    t.decimal "variant_price_modifier", precision: 10, scale: 2, default: "0.0"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["type", "status"], name: "idx_order_items_type_status"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "customer_info"
    t.jsonb "delivery_address"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "estimated_ready_at", precision: nil
    t.uuid "offer_id"
    t.decimal "paid_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "pickup_time", precision: nil
    t.string "promo_code", limit: 50
    t.uuid "restaurant_id", null: false
    t.uuid "session_id"
    t.jsonb "split_config"
    t.string "status", limit: 20, default: "pending"
    t.uuid "table_id"
    t.decimal "tip_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.string "type", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id", "status"], name: "idx_orders_restaurant_status"
    t.index ["restaurant_id"], name: "index_orders_on_restaurant_id"
    t.index ["session_id"], name: "index_orders_on_session_id"
  end

  create_table "owners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "restaurants", default: []
    t.string "user_id", limit: 128, null: false
    t.index ["user_id"], name: "index_owners_on_user_id", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "method", limit: 20, default: "card"
    t.uuid "order_id", null: false
    t.string "status", limit: 20, default: "pending"
    t.string "stripe_payment_intent_id", limit: 255
    t.decimal "tip_amount", precision: 10, scale: 2, default: "0.0"
    t.string "user_id", limit: 128, null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "reservations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email", limit: 255, default: ""
    t.string "customer_name", limit: 255, null: false
    t.string "customer_phone", limit: 50, default: ""
    t.string "date", limit: 10, null: false
    t.integer "duration_minutes", default: 90
    t.text "notes"
    t.integer "party_size", null: false
    t.uuid "restaurant_id", null: false
    t.uuid "restaurant_table_id"
    t.string "status", limit: 20, default: "confirmed"
    t.string "time", limit: 5, null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 128
    t.index ["restaurant_id", "date", "status"], name: "idx_reservations_restaurant_date_status"
    t.index ["restaurant_id"], name: "index_reservations_on_restaurant_id"
    t.index ["restaurant_table_id"], name: "index_reservations_on_restaurant_table_id"
  end

  create_table "restaurant_tables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "capacity", default: 4
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "number", null: false
    t.text "qr_code_url", default: ""
    t.uuid "restaurant_id", null: false
    t.string "status", limit: 20, default: "available"
    t.index ["restaurant_id", "number"], name: "index_restaurant_tables_on_restaurant_id_and_number", unique: true
    t.index ["restaurant_id"], name: "index_restaurant_tables_on_restaurant_id"
  end

  create_table "restaurants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "address", default: {"city"=>"", "street"=>"", "country"=>"BE", "postalCode"=>""}
    t.text "banner_image_url", default: ""
    t.datetime "created_at", null: false
    t.jsonb "cuisine", default: []
    t.string "currency", limit: 10, default: "EUR"
    t.text "description", default: ""
    t.text "google_business_url", default: ""
    t.jsonb "hours", default: {}
    t.string "locale", limit: 10, default: "fr-BE"
    t.text "logo_url", default: ""
    t.string "name", limit: 255, null: false
    t.string "owner_id", limit: 128, null: false
    t.jsonb "settings", default: {"dineInMode"=>"ordering", "orderTypes"=>{"dineIn"=>true, "delivery"=>false, "takeaway"=>false}, "requiresAccount"=>{"delivery"=>true, "takeaway"=>true}}
    t.string "slug", limit: 100, null: false
    t.string "status", limit: 20, default: "active", null: false
    t.jsonb "stripe", default: {"pricingModel"=>"transaction", "stripeAccountId"=>"", "onboardingComplete"=>false, "platformFeePercent"=>2}
    t.string "tagline", limit: 255, default: ""
    t.decimal "tax_rate", precision: 5, scale: 2, default: "21.0"
    t.jsonb "theme", default: {"logoUrl"=>"", "menuStyle"=>"cards", "textColor"=>"#1f2937", "fontFamily"=>"Inter", "primaryColor"=>"#000000", "bannerImageUrl"=>"", "secondaryColor"=>"#f59e0b", "backgroundColor"=>"#ffffff", "backgroundImageUrl"=>""}
    t.string "timezone", limit: 50, default: "Europe/Brussels"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_restaurants_on_owner_id"
    t.index ["slug"], name: "index_restaurants_on_slug", unique: true
  end

  create_table "reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "feedback"
    t.uuid "order_id", null: false
    t.integer "rating", null: false
    t.boolean "redirected_to_google", default: false
    t.uuid "restaurant_id", null: false
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["restaurant_id"], name: "index_reviews_on_restaurant_id"
  end

  create_table "session_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dining_session_id", null: false
    t.string "display_name", limit: 255, default: "Guest"
    t.datetime "joined_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "user_id", limit: 128, null: false
    t.index ["dining_session_id"], name: "index_session_members_on_dining_session_id"
  end

  create_table "staff_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "assigned_tables", default: []
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", limit: 255, null: false
    t.string "name", limit: 255, null: false
    t.uuid "restaurant_id", null: false
    t.string "role", limit: 20, null: false
    t.string "user_id", limit: 128, null: false
    t.index ["restaurant_id"], name: "index_staff_members_on_restaurant_id"
    t.index ["user_id"], name: "index_staff_members_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "customer", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "menus", on_delete: :cascade
  add_foreign_key "categories", "restaurants", on_delete: :cascade
  add_foreign_key "customer_addresses", "restaurants", on_delete: :cascade
  add_foreign_key "dining_sessions", "restaurant_tables"
  add_foreign_key "dining_sessions", "restaurants", on_delete: :cascade
  add_foreign_key "menu_items", "categories", on_delete: :cascade
  add_foreign_key "menu_items", "menus", on_delete: :cascade
  add_foreign_key "menu_items", "restaurants", on_delete: :cascade
  add_foreign_key "menus", "restaurants", on_delete: :cascade
  add_foreign_key "offers", "restaurants", on_delete: :cascade
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "orders", "restaurants", on_delete: :cascade
  add_foreign_key "payments", "orders", on_delete: :cascade
  add_foreign_key "reservations", "restaurant_tables"
  add_foreign_key "reservations", "restaurants", on_delete: :cascade
  add_foreign_key "restaurant_tables", "restaurants", on_delete: :cascade
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "restaurants", on_delete: :cascade
  add_foreign_key "session_members", "dining_sessions", on_delete: :cascade
  add_foreign_key "staff_members", "restaurants", on_delete: :cascade
end
