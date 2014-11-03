class AddItemIdtoTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :item_id, :string
  end
end
