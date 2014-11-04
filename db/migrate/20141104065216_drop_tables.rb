class DropTables < ActiveRecord::Migration
  def up
    drop_table :budget_events
    drop_table :financial_summaries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
