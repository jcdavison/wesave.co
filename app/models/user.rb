class User < ActiveRecord::Base
  attr_accessor :banking_data
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :institutions, dependent: :destroy
  has_many :messages, dependent: :destroy

  def set_phone number
    self.phone_number = number
    self.save
  end

  def summary_data institution
    @banking_data ||= extract_data Plaid.get_data institution
  end

  def active_institutions
    institutions.valid_tokens
  end

  def update_banking_snapshot
    create_institution_accounts
    create_account_entities
  end

  def create_institution_accounts 
    active_institutions.each do |institution|
      account_data = summary_data institution
      institution.create_accounts account_data
    end
  end

  def create_account_entities
    active_institutions.each do |institution|
      account_data = summary_data institution
      institution.accounts.each do |account|
        account.create_transactions account_data
        account.create_balances account_data
      end
    end
  end

  def extract_data api_response
    {accounts: api_response['accounts'], 
      transactions: api_response['transactions']}
  end

  def create_account_details data
    Account.generate_entities data
  end

  def primary_account
    institutions.inject([]) do |account, institution|
      institution.accounts.each {|a| account.push(a) if a.primary == true}
      account
    end.pop
  end
end
