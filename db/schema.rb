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

ActiveRecord::Schema[7.2].define(version: 2025_05_01_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "industry"
    t.integer "stage", default: 0
    t.integer "team_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_check_constraint "companies", "stage = ANY (ARRAY[0, 1, 2, 3])", name: "chk_companies_stage", validate: false

  create_table "diagnostics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_id", null: false
    t.integer "status", default: 0
    t.jsonb "raw_responses"
    t.integer "fit_score"
    t.string "critical_pain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "commercial_inputs", default: {}
    t.jsonb "commercial_outputs", default: {}
    t.index ["commercial_inputs"], name: "index_diagnostics_on_commercial_inputs", using: :gin
    t.index ["commercial_outputs"], name: "index_diagnostics_on_commercial_outputs", using: :gin
    t.index ["lead_id"], name: "index_diagnostics_on_lead_id"
  end

  add_check_constraint "diagnostics", "status = ANY (ARRAY[0, 1, 2, 3])", name: "chk_diagnostics_status", validate: false

  create_table "journey_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "strategy_plan_id", null: false
    t.string "stage_name", null: false
    t.text "description"
    t.jsonb "action_items"
    t.integer "order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy_plan_id", "order"], name: "idx_journey_stages_on_plan_and_order", unique: true
    t.index ["strategy_plan_id"], name: "index_journey_stages_on_strategy_plan_id"
  end

  create_table "leads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "company_id", null: false
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_leads_on_company_id"
    t.index ["email"], name: "index_leads_on_email", unique: true
  end

  create_table "strategy_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "diagnostic_id", null: false
    t.text "executive_summary"
    t.string "audio_briefing_url"
    t.jsonb "kpis"
    t.jsonb "okrs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnostic_id"], name: "index_strategy_plans_on_diagnostic_id"
  end

  add_foreign_key "diagnostics", "leads"
  add_foreign_key "journey_stages", "strategy_plans"
  add_foreign_key "leads", "companies"
  add_foreign_key "strategy_plans", "diagnostics"
end
