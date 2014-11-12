require 'rails_helper'

RSpec.describe Institution, :type => :model do
  include_context 'plaid sandbox authorization'
  before do 
    @institution = @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
  end

  it 'ensures unique tokens' do
    expect(@institution.save).to be true
    duplicate_institution = @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
    expect(duplicate_institution.save).to be false
  end

  context '.validate_token!' do
    it 'valid_token == true' do
      @institution.save
      @institution.validate_token!
      expect(@institution.valid_token).to be true
    end
  end
end
