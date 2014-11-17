class Author
  attr_accessor :message, :account, :transactions

  def initialize account
    @message = []
    @account = account
    @month_to_day_transactions = month_to_day_transactions
  end

  def self.perform account
    self.new(account).create_message
  end

  def month_to_day_transactions
    account.month_to_day_transactions
  end

  def create_message
    [ :previous_24_message,
      :month_to_day_message,
      :current_balance_message,
      :avg_daily_spend_message,
      :projected_daily_spend_message].each do |method|
      message.push self.send method
    end
    message.join(" ")
  end

  def current_balance_message
    "You currently have $#{most_recent_balance}."
  end

  def most_recent_balance
    account.most_recent_balance
  end

  def month_to_day_message
    "You have spent $#{sum_month_to_day} so far this month."
  end

  def sum_month_to_day
    account.sum_month_to_day
  end

  def previous_24_message
    "You spent $#{sum_previous_24_hours} in the last 24hrs."
  end

  def sum_previous_24_hours
    account.sum_previous_24_hours
  end

  def avg_daily_spend_message
    "You have spent $#{avg_daily_spend} per day."
  end

  def avg_daily_spend
    account.avg_daily_spend
  end

  def projected_daily_spend_message
    "You can spend $#{projected_daily_spend} daily for the rest of the month."
  end

  def projected_daily_spend
    account.projected_daily_spend
  end
end
