FactoryGirl.define do
  factory :user do
    email 'test@plaid.com'
    password 'test1234'
    password_confirmation 'test1234'
  end
end
