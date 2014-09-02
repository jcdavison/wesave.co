class Institution < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :token, :name
  before_save :downcase_name

  def downcase_name
   self.name = self.name.downcase
  end
end
