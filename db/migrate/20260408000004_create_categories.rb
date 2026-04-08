class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.references :menu, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, limit: 255, null: false
      t.text :description, default: ""
      t.text :image_url, default: ""
      t.text :featured_image_url, default: ""
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
