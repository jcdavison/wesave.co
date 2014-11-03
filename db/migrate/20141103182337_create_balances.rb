class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.integer :account_id
      t.float :value

      t.timestamps
    end
  end
end
