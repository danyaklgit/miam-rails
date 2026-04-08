class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :type, limit: 20, null: false
      t.string :name, limit: 255, null: false
      t.decimal :value, precision: 10, scale: 2, null: false
      t.jsonb :applies_to, default: { items: [], categories: [], wholeOrder: false }
      t.jsonb :schedule
      t.string :promo_code, limit: 50
      t.boolean :active, default: true
      t.integer :max_redemptions
      t.integer :current_redemptions, default: 0
      t.decimal :min_order_amount, precision: 10, scale: 2
      t.jsonb :order_types, default: ["dineIn", "takeaway", "delivery"]

      t.timestamps
    end
  end
end
