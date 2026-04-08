class CreateStaffMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_members, id: :uuid do |t|
      t.string :user_id, limit: 128, null: false
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, limit: 255, null: false
      t.string :email, limit: 255, null: false
      t.string :role, limit: 20, null: false
      t.jsonb :assigned_tables, default: []

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :staff_members, :user_id
  end
end
