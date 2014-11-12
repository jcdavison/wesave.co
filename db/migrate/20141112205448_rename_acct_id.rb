class RenameAcctId < ActiveRecord::Migration
  def change
    rename_column :accounts, :acct_id, :institutional_account_id
  end
end
