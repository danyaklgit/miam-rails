class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews, id: :uuid do |t|
      t.references :restaurant, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :feedback
      t.boolean :redirected_to_google, default: false

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
