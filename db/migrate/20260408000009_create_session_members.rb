class CreateSessionMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :session_members, id: :uuid do |t|
      t.references :dining_session, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :user_id, limit: 128, null: false
      t.string :display_name, limit: 255, default: "Guest"

      t.timestamp :joined_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
