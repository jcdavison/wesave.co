class ChangeInstitutionTypetoName < ActiveRecord::Migration
  def change
    rename_column :account_balances, :type, :name
  end
end
