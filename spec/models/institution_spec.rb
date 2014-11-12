require 'rails_helper'

RSpec.describe Institution, :type => :model do
  include_context 'plaid sandbox authorization'

  context 'does not allow duplicates' do
    it 'ensures unique tokens' do
      @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
      expect(@user.save).to be true
      @user.institutions.new(name: @params[:institution][:type], token: @api_data['access_token'])
      expect(@user.save).to be false
    end
  end
end
