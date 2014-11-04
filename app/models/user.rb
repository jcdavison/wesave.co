class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :institutions, dependent: :destroy
  has_many :budget_events, dependent: :destroy
  has_many :financial_summaries, dependent: :destroy

  def set_phone number
    self.phone_number = number
    self.save
  end

  def institutions_with_active_tokens
    self.institutions.valid_tokens
  end

  def collect_initial_data
    institutions = self.institutions_with_active_tokens
    institutions.each do |institution|
      api_response = Plaid.get_connect institution
      create_accounts institution, api_response['accounts']
      create_balances institution, api_response['accounts']
      create_transactions institution, api_response['transactions']
    end
  end

  def create_transactions institution, transaction_data
    transaction_data.each do |transaction|
      account = institution.accounts.find_by_acct_id transaction['_account']
      unless account.transactions.find_by_item_id transaction['_id']
        date = Date.strptime transaction['date'], "%Y-%m-%d"
        account.transactions.create amount: transaction['amount'], 
          date: date, name: transaction['name'], item_id: transaction['_id']
      end
    end
  end

  def create_balances institution, balances_data 
    balances_data.each do |balance_obj|
      account = institution.accounts.find_by_acct_id balance_obj['_id']
      unless account.balances.find_by_item_id balance_obj['_item']
        account.balances.create! value: balance_obj['balance']['current'],
          item_id: balance_obj['_item'] 
      end
    end
  end

  def create_accounts institution, accounts_data
    accounts_data.each do |account_obj|
      unless institution.accounts.find_by_acct_id account_obj['_id']
        institution.accounts.create acct_id: account_obj['_id'],
          financial_type: account_obj['type'], name: account_obj['meta']['name']  
      end
    end
  end

  def balance_of_interest
    #this method is way gross, logic is gonna need some rethinking
    institution = self.institutions.valid_tokens.first
    institution.account_balances.select {|balance| balance.function == institution.account_of_concern }.first
  end

  def revenues
    self.budget_events.select {|event| event.value >= 0}
  end

  def expenses
    self.budget_events.select {|event| event.value < 0}
  end

  def last_balance
    self.institutions.valid_tokens.first.account_balances.last
  end
end
