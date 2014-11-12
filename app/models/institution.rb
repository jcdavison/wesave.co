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

  def set_primary! institutional_account_id 
    account = accounts.find_by_institutional_account_id(institutional_account_id)
    account.update(primary: true)
  end

  def has_primary?
    accounts.find {|account| account.primary == true}
  end

  def validate_token!
    update_attributes(valid_token: true)
  end

  def create_accounts args
    args[:accounts].each do |account|
      unless self.accounts.find_by_institutional_account_id account['_id']
        self.accounts.create institutional_account_id: account['_id'],
          financial_type: account['type'], name: account['meta']['name']  
      end
    end
  end
end
