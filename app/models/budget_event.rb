class BudgetEvent < ActiveRecord::Base
  belongs_to :user

  scope :revenues, -> { where("value > 0")}
  scope :expenses, -> { where("value < 0")}
end
