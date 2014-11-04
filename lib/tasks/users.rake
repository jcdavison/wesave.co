namespace :users do
  desc "Collect account data for all Users w/ valid tokens."
  task :collect_account_data => :environment do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      user.collect_initial_data
    end
  end
end
