class CreateAccountBalances < ActiveRecord::Migration
  def change
    create_table :account_balances do |t|
      t.float :value
      t.integer :institution_id

      t.timestamps
    end
  end
end
