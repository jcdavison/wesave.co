namespace :users do
  desc "Collect account data for all Users w/ valid tokens."
  task :collect_account_data => :environment do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      user.collect_initial_data
    end
  end

  task :send_sms => do
    users = User.all.select {|user| user.institutions_with_active_tokens}
    users.each do |user|
      message = Author.perform(user.primary_account).create_message
      Sms.send message, user.number
    end
  end
end
