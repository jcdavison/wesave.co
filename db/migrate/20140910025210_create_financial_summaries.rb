class CreateFinancialSummaries < ActiveRecord::Migration
  def change
    create_table :financial_summaries do |t|
      t.float :value
      t.string :user_id
      t.string :integer

      t.timestamps
    end
  end
end
