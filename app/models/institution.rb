class Institution < ActiveRecord::Base
  belongs_to :user
  has_many :accounts, dependent: :destroy
  validates_presence_of :token, :name
  before_save :downcase_name

  scope :valid_tokens, -> { where(valid_token: true)}

  def downcase_name
   self.name = self.name.downcase
  end

  def set_primary! account_name
    account = accounts.find_by_name(account_name)
    account.primary = true
    account.save
  end

  def has_primary?
    accounts.any? {|account| account.primary == true}
  end
end
