class AddTypetoAccountBalance < ActiveRecord::Migration
  def change
    add_column :account_balances, :type, :string
  end
end
