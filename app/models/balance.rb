class Balance < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :value
end
