class AddValidtoInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :valid_token, :boolean, :default => false
  end
end
