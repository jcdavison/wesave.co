class Institution < ActiveRecord::Base
  belongs_to :user
  has_many :accounts, dependent: :destroy
  validates_presence_of :token, :name
  validates_uniqueness_of :token
  before_save :downcase_name

  scope :valid_tokens, -> { where(valid_token: true) }

  def downcase_name
   self.name = self.name.downcase
  end

  def set_primary! account_name
    accounts.find_by_name(account_name).update(primary: true)
  end

  def has_primary?
    accounts.any? {|account| account.primary == true}
  end

  def validate_token!
    self.valid_token = true
    self.save
  end

  def create_accounts args
    args[:accounts].each do |account|
      unless self.accounts.find_by_acct_id account['_id']
        self.accounts.create acct_id: account['_id'],
          financial_type: account['type'], name: account['meta']['name']  
      end
    end
  end
end
