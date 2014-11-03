class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :acct_id
      t.string :financial_type
      t.string :name
      t.integer :institution_id
      t.boolean :primary, default: false

      t.timestamps
    end
  end
end
