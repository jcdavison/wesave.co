class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :institutions, dependent: :destroy
  has_many :budget_events, dependent: :destroy
  has_many :financial_summaries, dependent: :destroy

  def institutions_with_active_tokens
    self.institutions.valid_tokens
  end

  def collect_balance_data
    institutions = self.institutions_with_active_tokens
    institutions.each do |institution|
      summaries = Plaid.get_account_summary institution
      summaries.each do |summary|
        institution.account_balances.create function: summary[:account_name], value: summary[:balance]
      end
    end
  end

  def balance_of_interest
    #this method is way gross, code is gonna need some refactoring
    institution = self.institutions.valid_tokens.first
    institution.account_balances.select {|balance| balance.function == institution.account_of_concern }.first
  end

  def revenues
    self.budget_events.select {|event| event.value >= 0}
  end

  def expenses
    self.budget_events.select {|event| event.value < 0}
  end
end
