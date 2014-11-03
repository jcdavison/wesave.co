class Transaction < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :amount, :name, :date, :account_id
end
