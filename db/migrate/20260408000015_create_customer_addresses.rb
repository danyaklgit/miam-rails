class CreateCustomerAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_addresses, id: :uuid do |t|
      t.string :user_id, limit: 128, null: false
      t.references :restaurant, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :label, limit: 100, default: ""
      t.string :street, limit: 255, null: false
      t.string :city, limit: 100, null: false
      t.string :postal_code, limit: 20, null: false
      t.string :country, limit: 10, default: "BE"
      t.text :instructions, default: ""
      t.boolean :is_default, default: false

      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :customer_addresses, :user_id
  end
end
