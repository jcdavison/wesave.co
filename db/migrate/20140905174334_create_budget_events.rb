class CreateBudgetEvents < ActiveRecord::Migration
  def change
    create_table :budget_events do |t|
      t.string :description
      t.float :value
      t.integer :user_id

      t.timestamps
    end
  end
end
