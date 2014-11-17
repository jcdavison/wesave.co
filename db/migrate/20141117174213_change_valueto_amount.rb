class ChangeValuetoAmount < ActiveRecord::Migration
  def change
    rename_column :balances, :value, :amount
  end
end
