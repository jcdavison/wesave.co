require 'rails_helper'

RSpec.describe Account, :type => :model do
  include_context 'plaid sandbox authorization'
  before do
    @institution = @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
    @institution.save
    @data = Plaid.get_data @institution
    @institution.create_accounts @data
    @institution.set_primary! @user.institutions.first.accounts.first.institutional_account_id
    @account = @user.primary_account
  end

  context 'composition object Transaction' do
    it 'create_transactions calls create_transaction only for transactions that match the institutional_account_id' do
      qty_method_calls = @data[:transactions].select {|t| t["_account"] == @account.institutional_account_id }.length    
      expect(@account).to receive(:create_transaction).exactly(qty_method_calls).times 
      @account.create_transactions @data
    end
  end

  context 'composition object Balance' do
    it 'create_balances calls create_balance only for transactions that match the institutional_account_id' do
      qty_method_calls = @data[:accounts].select {|a| a["_id"] == @account.institutional_account_id }.length    
      expect(@account).to receive(:create_balance).exactly(qty_method_calls).times 
      @account.create_balances @data
    end
  end
end
