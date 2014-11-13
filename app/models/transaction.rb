class Transaction < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :amount, :date, :account_id
  scope :expenses, -> { where('amount > 0') }
end
