namespace :users do
  desc "Collect account balances for all Users with valid institution tokens."
  task :collect_account_summaries => :environment do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      user.collect_balance_data
      summary = user.financial_summaries.new
      summary.set_value!
    end
  end

  desc 'Send Love Note'
  task :lovenote => :environment do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      summary = user.financial_summaries.last
      daily_discretionary = summary.daily_discretionary_allowance
      love_note = FinancialLoveNote.create summary.value, daily_discretionary
      Sms.send! love_note, user.phone_number
    end
  end
end


