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

ActiveRecord::Schema.define(version: 20130818182250) do

  create_table "appointments", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.datetime "remind_at"
    t.boolean  "use_html_email",        default: false
    t.boolean  "use_text_email",        default: false
    t.boolean  "use_text_message",      default: false
    t.integer  "service_id"
    t.integer  "staff_member_id"
    t.integer  "reminder_email_job_id"
    t.integer  "text_message_job_id"
    t.integer  "repeat_in_days",        default: 0
  end

  add_index "appointments", ["company_id"], name: "index_appointments_on_company_id"
  add_index "appointments", ["customer_id"], name: "index_appointments_on_customer_id"
  add_index "appointments", ["service_id"], name: "index_appointments_on_service_id"
  add_index "appointments", ["staff_member_id"], name: "index_appointments_on_staff_member_id"
  add_index "appointments", ["user_id"], name: "index_appointments_on_user_id"

  create_table "assignments", force: :cascade do |t|
    t.integer  "slot_id"
    t.integer  "staff_member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["slot_id"], name: "index_assignments_on_slot_id"
  add_index "assignments", ["staff_member_id"], name: "index_assignments_on_staff_member_id"

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "company_register_id"
    t.string   "bank_account_number"
    t.string   "bank_id"
    t.string   "bank_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_html_email",                default: true
    t.boolean  "use_text_email",                default: true
    t.boolean  "use_text_message",              default: true
    t.integer  "reminder_interval",             default: 86400
    t.string   "public_identifier"
    t.string   "street_address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.string   "phone_number"
    t.string   "vat_id"
    t.string   "website_url"
    t.string   "logo_url"
    t.boolean  "send_appointment_confirmation", default: false
    t.string   "ics_identifier"
  end

  create_table "customer_sets", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "mobile_phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_html_email",                  default: false
    t.boolean  "use_text_email",                  default: false
    t.boolean  "use_text_message",                default: false
    t.string   "email_confirmation_token"
    t.string   "mobile_phone_confirmation_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "email_confirmed_at"
    t.datetime "mobile_phone_confirmed_at"
    t.integer  "customer_set_id"
  end

  add_index "customers", ["company_id"], name: "index_customers_on_company_id"
  add_index "customers", ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true
  add_index "customers", ["customer_set_id"], name: "index_customers_on_customer_set_id"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories"

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.integer  "duration"
    t.integer  "appointment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  add_index "services", ["company_id"], name: "index_services_on_company_id"

  create_table "slots", force: :cascade do |t|
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weekday"
    t.integer  "starts_at_hour"
    t.integer  "starts_at_minute"
    t.integer  "ends_at_hour"
    t.integer  "ends_at_minute"
    t.boolean  "blocker",          default: false
  end

  add_index "slots", ["company_id"], name: "index_slots_on_company_id"

  create_table "staff_members", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "company_id"
    t.string   "colour",     default: "#3a87ad", null: false
  end

  add_index "staff_members", ["company_id"], name: "index_staff_members_on_company_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "company_id"
    t.string   "country"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id"
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

end
