class AddAccountofConcernToInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :account_of_concern, :string
  end
end
