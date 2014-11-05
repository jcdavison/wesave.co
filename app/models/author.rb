class Author
  # all the business logic needs to be refactored out!

  attr_accessor :message, :account, :transactions
  def initialize account
    @message = []
    @account = account
    @month_to_day_transactions = month_to_day_transactions
  end

  def self.perform account
    self.new(account).create_message
  end

  def create_message
    [ :month_to_day_message, :previous_24_message, :avg_daily_spend_message,
      :projected_daily_spend_message, :current_balance_message ].each do |method|
      message.push self.send method
    end
    message.join(" ")
  end

  def current_balance_message
    "You currently have an account balance of $#{most_recent_balance}."
  end

  def month_to_day_message
    "Month to day you have spent $#{sum_month_to_day}." 
  end

  def previous_24_message
    "In the last 24 hours you have spent $#{sum_previous_24_hours}."
  end

  def avg_daily_spend_message
    "You have spent on average $#{avg_daily_spend} per day."
  end

  def projected_daily_spend_message
    "You can spend $#{projected_daily_spend} each day for the rest of the month."
  end

  def most_recent_balance
    account.balances.last.value.to_f.round(2).abs
  end

  def projected_daily_spend
    remaining_days = Time::days_in_month(Time.now.month, Time.now.year) - Time.now.day
    (most_recent_balance / remaining_days).round(2).abs
  end

  def avg_daily_spend
    (sum_month_to_day / Time.now.day).round(2).abs
  end

  def sum_month_to_day
    month_to_day_transactions.map {|t| t.amount.to_f }.reduce(:+).round(2).abs
  end

  def sum_previous_24_hours
    previous_24_hrs_transactions.map {|t| t.amount.to_f }.reduce(:+).round(2).abs
  end

  def month_to_day_transactions
    begin_range = (Time.now - (Time.now.day).days).midnight
    end_range = Time.now
    account.transactions.where(date: begin_range..end_range)
  end

  def previous_24_hrs_transactions
    begin_range = (Time.now - 24.hours)
    end_range = Time.now
    month_to_day_transactions.where(date: begin_range..end_range)
  end
end
