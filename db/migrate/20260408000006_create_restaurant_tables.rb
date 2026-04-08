class CreateRestaurantTables < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurant_tables, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :number, null: false
      t.integer :capacity, default: 4
      t.text :qr_code_url, default: ""
      t.string :status, limit: 20, default: "available"

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :restaurant_tables, [:restaurant_id, :number], unique: true
  end
end
