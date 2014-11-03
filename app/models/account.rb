class Account < ActiveRecord::Base
  belongs_to :institution
  validates_presence_of :bank_id, :financial_type, :name, :institution_id
end
