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

ActiveRecord::Schema[7.1].define(version: 2025_03_13_010001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "analyses", force: :cascade do |t|
    t.string "status"
    t.float "score"
    t.datetime "timestamp"
    t.jsonb "components"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "api_data"
    t.text "error_message"
    t.datetime "processed_at"
  end

  create_table "analysis_results", force: :cascade do |t|
    t.bigint "analysis_id", null: false
    t.bigint "component_id"
    t.float "position_x"
    t.float "position_y"
    t.float "rotation"
    t.float "conformity_score"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "raw_data"
    t.string "defect_type"
    t.index ["analysis_id"], name: "index_analysis_results_on_analysis_id"
    t.index ["component_id"], name: "index_analysis_results_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "reference_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "defect_detections", force: :cascade do |t|
    t.json "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "analysis_results", "analyses"
  add_foreign_key "analysis_results", "components"
end
