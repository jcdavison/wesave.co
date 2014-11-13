namespace :users do
  desc "Collect account data for all Users w/ valid tokens."
  task :refresh_account_data => :environment do
    User.update_all_banking_information
  end

  task :send_sms => :environment do
    users = User.all.select {|user| user.active_institutions}
    users.each do |user|
      next unless account = user.primary_account
      message = Author.perform(account)
      Sms.send message, user.phone_number
    end
  end
end
