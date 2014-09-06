class AddMonthDayToBudgetEvent < ActiveRecord::Migration
  def change
    add_column :budget_events, :month_day, :integer, default: 1
  end
end
