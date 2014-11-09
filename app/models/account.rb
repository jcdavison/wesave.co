class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :balances, dependent: :destroy
  has_many :transactions, dependent: :destroy
  validates_presence_of :acct_id, :financial_type, :name

  def create_transactions data
    data[:transactions].each do |transaction|
      create_transaction transaction
    end
  end

  def create_transaction transaction
    unless transactions.find_by_item_id transaction['_id']
      date = Date.strptime transaction['date'], "%Y-%m-%d"
      transactions.create amount: transaction['amount'], 
        date: date, name: transaction['name'], item_id: transaction['_id']
    end
  end

  def create_balances data
    data[:accounts].each do |account_summary|
      create_balance account_summary
    end
  end

  def create_balance account_summary
    unless balances.find_by_item_id account_summary['_item']
      balances.create! value: account_summary['balance']['current'],
        item_id: account_summary['_item'] 
    end
  end

  def most_recent_balance
    balance = balances.last.value.to_f || 0
    balance.round(2).abs
  end

  def month_to_day_transactions
    begin_range = (Time.now - (Time.now.day).days).midnight
    end_range = Time.now
    transactions.where(date: begin_range..end_range)
  end

  def projected_daily_spend
    remaining_days_in_month = Time::days_in_month(Time.now.month, Time.now.year) - Time.now.day
    (most_recent_balance / remaining_days_in_month).round(2).abs
  end

  def avg_daily_spend
    average_spend = (sum_month_to_day / Time.now.day) || 0
    average_spend.round(2).abs
  end

  def sum_month_to_day
    sum = month_to_day_transactions.map {|t| t.amount.to_f }.reduce(:+)
    sum.round(2).abs
  end

  def previous_24_hrs_transactions
    begin_range = (Time.now - 24.hours)
    end_range = Time.now
    month_to_day_transactions.where(date: begin_range..end_range)
  end

  def sum_previous_24_hours
    sum = previous_24_hrs_transactions.map {|t| t.amount.to_f }.reduce(:+) || 0 
    sum.round(2).abs
  end
end
