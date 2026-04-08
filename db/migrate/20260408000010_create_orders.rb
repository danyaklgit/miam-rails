class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.uuid :session_id
      t.uuid :table_id
      t.string :type, limit: 20, null: false
      t.string :status, limit: 20, default: "pending"
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.decimal :paid_amount, precision: 10, scale: 2, default: 0
      t.decimal :tip_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.uuid :offer_id
      t.jsonb :customer_info
      t.jsonb :delivery_address
      t.timestamp :pickup_time
      t.string :promo_code, limit: 50
      t.timestamp :estimated_ready_at

      t.timestamps
    end

    add_index :orders, :session_id
    add_index :orders, [:restaurant_id, :status], name: "idx_orders_restaurant_status"
  end
end
