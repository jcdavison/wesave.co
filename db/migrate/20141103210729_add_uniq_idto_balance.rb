class AddUniqIdtoBalance < ActiveRecord::Migration
  def change
    add_column :balances, :item_id, :string
  end
end
