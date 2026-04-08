class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :menu, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, limit: 255, null: false
      t.text :description, default: ""
      t.decimal :price, precision: 10, scale: 2, null: false
      t.jsonb :images, default: []
      t.jsonb :allergens, default: []
      t.jsonb :tags, default: []
      t.string :type, limit: 10, null: false, default: "food"
      t.boolean :available, default: true
      t.jsonb :variants, default: []
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
