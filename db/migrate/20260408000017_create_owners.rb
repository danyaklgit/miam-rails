class CreateOwners < ActiveRecord::Migration[8.1]
  def change
    create_table :owners, id: :uuid do |t|
      t.string :user_id, limit: 128, null: false
      t.jsonb :restaurants, default: []

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :owners, :user_id, unique: true
  end
end
