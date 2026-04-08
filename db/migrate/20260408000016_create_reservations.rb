class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :restaurant_table, type: :uuid, foreign_key: true
      t.string :status, limit: 20, default: "confirmed"
      t.string :date, limit: 10, null: false
      t.string :time, limit: 5, null: false
      t.integer :party_size, null: false
      t.integer :duration_minutes, default: 90
      t.string :customer_name, limit: 255, null: false
      t.string :customer_phone, limit: 50, default: ""
      t.string :customer_email, limit: 255, default: ""
      t.string :user_id, limit: 128
      t.text :notes

      t.timestamps
    end

    add_index :reservations, [:restaurant_id, :date, :status], name: "idx_reservations_restaurant_date_status"
  end
end
