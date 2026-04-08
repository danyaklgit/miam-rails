class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, limit: 255, null: false
      t.text :description, default: ""
      t.boolean :is_active, default: true
      t.jsonb :schedule, default: { type: "always", days: [], startTime: "", endTime: "" }
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
