class Institution < ActiveRecord::Base
  belongs_to :user
  has_many :account_balances
  validates_presence_of :token, :name
  before_save :downcase_name

  scope :valid_tokens, -> { where(valid_token: true)}

  def downcase_name
   self.name = self.name.downcase
  end
end
