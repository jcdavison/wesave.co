class Plaid
  attr_accessor :client_id, :secret, :api_server
  def initialize
    @api_server = 'https://tartan.plaid.com'
    @client_id = PLAID_CLIENT_ID
    @secret = PLAID_SECRET
  end

  def self.institution_names
    self.institutions.map {|i| i["name"] }
  end


  def self.mfa_details
    self.institutions.inject({}) do |hash, element| 
      hash[element["name"]] = element["mfa"]
      hash
    end
  end

  def initiate_auth params, user_email
    Excon.post("#{@api_server}/connect",
               query: connect_query(params[:institution], user_email))
  end

  def connect_query institution, user_email
    query = { 
      :client_id => client_id,
      :secret => secret,
      :credentials => {
        :username => institution[:username], 
        :password => institution[:password],
        :pin => institution[:pin]
        }, 
      :type => set_type(institution[:type]),
      :email => user_email 
    }
    query[:credentials] = JSON.generate(query[:credentials])
    plaid_test_credentials query
    query
  end

  def set_type institution
    Plaid.institutions[institution]
  end

  def self.institutions
    { "American Express" => "amex",
      "Bank of America" => "bofa", 
      "Chase" => "chase", 
      "Citi" => "citi", 
      "US Bank" => "us",
      "USAA" => "usaa",
      "Wells Fargo" => "wells" }
  end

  def mfa_step params, institution
    query = mfa_query(params, institution.token)
    query = type_if_sandbox!(query, institution.name)
    Excon.post("#{@api_server}/connect/step", query: query)
  end

  def mfa_query params, token
    query = { 
      :client_id => client_id,
      :secret => secret,
      :mfa => params[:mfa][:answer],
      :access_token => token
      }
    plaid_test_credentials query
    query
  end

  def plaid_test_credentials query
    credentials = JSON.parse(query[:credentials]) if query[:credentials]
    # we have an access token or username
    if query[:access_token] == "test"
      set_sandbox_api query
    elsif credentials && credentials[:username] == "plaid_test"
      set_sandbox_api query
    end
    query
  end

  def set_sandbox_api query
    query[:client_id] = "test_id"
    query[:secret] = "test_secret"
    query
  end

  def type_if_sandbox! query, name
    # the api requires this in sandbox mode
    credentials = JSON.parse(query[:credentials]) if query[:credentials]
    if query[:access_token] == "test"
      query[:type] = name
    elsif credentials && credentials[:username] == "plaid_test"
      query[:type] = name
    end
    query
  end

  def query_object institution
    {access_token: institution.token , client_id: @client_id , secret: @secret} 
  end

  def self.get_user_data institution
    plaid = Plaid.new
    query = plaid.query_object institution
    JSON.parse(Excon.get("#{plaid.api_server}/connect", query: query ).body)
  end

  def self.summary account_data
    account_data["accounts"].map do |account|
      { balance: account["balance"]["current"], institution: account["institution_type"], account_name: account["meta"]["name"], account_last4: account["meta"]["number"] }
    end
  end

  def self.get_account_summary institution
    account_data = self.get_user_data institution
    account_summaries = self.summary account_data
  end
end
