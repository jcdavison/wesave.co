require 'rails_helper'

RSpec.shared_context "plaid sandbox authorization", :a => :b do
  before do
    @user = FactoryGirl.create :user
    @params = {institution: { username: 'plaid_test', password: 'plaid_good', type: 'Wells Fargo', pin: ''}}
    response = Plaid.new().initiate_auth @params, @user.email
    @api_data = JSON.parse(response.body)
  end
end
