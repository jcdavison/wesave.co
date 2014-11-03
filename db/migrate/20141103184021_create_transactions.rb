class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.string :name
      t.datetime :date
      t.integer :account_id

      t.timestamps
    end
  end
end
