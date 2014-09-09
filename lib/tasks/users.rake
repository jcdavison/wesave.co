namespace :users do
  desc "Collect account balances for all Users with valid institution tokens."
  task :collect_account_summaries => :environment do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      user.collect_balance_data
    end
  end
end
