class ChangeAcctNametoFunction < ActiveRecord::Migration
  def change
    rename_column :account_balances, :name, :function
  end
end
