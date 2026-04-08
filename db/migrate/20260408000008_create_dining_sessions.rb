class CreateDiningSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :dining_sessions, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :restaurant_table, type: :uuid, null: false, foreign_key: true
      t.uuid :order_id
      t.string :status, limit: 20, default: "active"

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamp :closed_at
    end

    add_index :dining_sessions, [:restaurant_id, :restaurant_table_id, :status], name: "idx_sessions_restaurant_table_status"
  end
end
