class Institution < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :token
end
