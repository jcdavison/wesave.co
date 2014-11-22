require 'rails_helper'

RSpec.describe Institution, :type => :model do
  include_context 'plaid sandbox authorization'
  before do 
    @institution = @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
  end

  context 'methods' do
    before do
      @institution.save
    end

    context '.validate_token!' do
      it 'valid_token == true' do
        @institution.validate_token!
        expect(@institution.valid_token).to be true
      end
    end

    context 'composition object Account' do
      before do
        @data = Plaid.get_data @institution
        @institution.create_accounts @data
      end

      it 'creates accounts for all api account objects' do
        @data[:accounts].each do |account|
          account_lookup = @institution.accounts.find_by_institutional_account_id account["_id"]
          expect(account_lookup).not_to be nil
        end
      end

      it 'does not duplicate accounts' do
        @institution.create_accounts @data
        total_accounts = @institution.accounts.length
        expect(total_accounts).to be @data[:accounts].length
      end

      context 'primary Account' do
        before do
          @institutional_account_id = @data[:accounts].first['_id']
          @institution.set_primary! @institutional_account_id
        end

        it 'set_primary!' do
          account = @institution.accounts.find_by_institutional_account_id @institutional_account_id
          expect(account.primary).to be true
        end

        it 'has_primary?' do
          expect(@institution.has_primary?).not_to be false
        end
      end
    end
  end
end
