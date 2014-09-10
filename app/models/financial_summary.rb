class FinancialSummary < ActiveRecord::Base
  belongs_to :user

  def budget
    self.user.revenues.map(&:value).reduce(:+)
  end

  def discretionary_allowance
    budget + fixed_expenses
  end

  def daily_discretionary_allowance
    (discretionary_allowance.to_f / 30).round(2)
  end

  def daily_discretionary_to_date
    - (daily_discretionary_allowance * Time.now.day).round(2)
  end

  def fixed_expenses
    self.user.expenses.map(&:value).reduce(:+)
  end

  def expenses_to_date
    expenses_so_far = self.user.expenses.select do |exp|
      exp.month_day <= Time.now.day
    end
    expenses_so_far.map(&:value).reduce(:+)
  end

  def projected_current_expenses
    (expenses_to_date + daily_discretionary_to_date).round(2)
  end

  def actual_current_balance
    self.user.balance_of_interest.value
  end

  def projected_current_balance
    (budget + projected_current_expenses).round(2)
  end

  def current_budget_status
    (actual_current_balance - projected_current_balance).round(2)
  end

  def set_value!
    self.value = current_budget_status
    self.save
  end
end
