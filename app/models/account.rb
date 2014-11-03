class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :balances
  has_many :transactions
  validates_presence_of :acct_id, :financial_type, :name, :institution_id
end
