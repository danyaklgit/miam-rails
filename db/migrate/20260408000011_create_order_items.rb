class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.uuid :menu_item_id
      t.string :name, limit: 255, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :quantity, default: 1
      t.text :notes, default: ""
      t.string :type, limit: 10, null: false, default: "food"
      t.string :status, limit: 20, default: "ordered"
      t.string :variant_id, limit: 100
      t.string :variant_name, limit: 255
      t.decimal :variant_price_modifier, precision: 10, scale: 2, default: 0
      t.string :claimed_by, limit: 128
      t.string :paid_by, limit: 128
      t.string :ordered_by, limit: 128, null: false

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :order_items, [:type, :status], name: "idx_order_items_type_status"
  end
end
