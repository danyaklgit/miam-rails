class AddSplitConfigToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :split_config, :jsonb
  end
end
