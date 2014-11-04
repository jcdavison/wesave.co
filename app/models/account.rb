class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :balances, dependent: :destroy
  has_many :transactions, dependent: :destroy
  validates_presence_of :acct_id, :financial_type, :name
end
