class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :institutions, dependent: :destroy


  def institutions_with_active_tokens
    self.institutions.valid_tokens
  end

  def collect_balance_data
    institutions = self.institutions_with_active_tokens
    institutions.each do |institution|
      summaries = Plaid.get_account_summary institution
      summaries.each do |summary|
        institution.account_balances.create name: summary[:institution], value: summary[:balance]
      end
    end
  end

end
