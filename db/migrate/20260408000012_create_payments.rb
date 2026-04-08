class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :user_id, limit: 128, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :tip_amount, precision: 10, scale: 2, default: 0
      t.string :stripe_payment_intent_id, limit: 255
      t.string :status, limit: 20, default: "pending"
      t.string :method, limit: 20, default: "card"

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
