class Plaid
  attr_accessor :client_id, :secret
  def initialize
    @api_server = 'https://tartan.plaid.com'
    @client_id = PLAID_CLIENT_ID
    @secret = PLAID_SECRET
  end

  def self.institution_names
    self.institutions.map {|i| i["name"] }
  end

  def self.institutions
    JSON.parse(Excon.get('https://tartan.plaid.com/institutions').body)
  end

  def self.mfa_details
    self.institutions.inject({}) do |hash, element| 
      hash[element["name"]] = element["mfa"]
      hash
    end
  end

  def initiate_auth params, user_email
    Excon.post("#{@api_server}/connect",
               query: connect_query(params, user_email))
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

  def connect_query params, user_email
    query = { 
      :client_id => client_id,
      :secret => secret,
      :credentials => {
        :username => params[:institution][:username], 
        :password => params[:institution][:password],
        :pin => params[:institution][:pin]
        }, 
      :type => params[:institution][:type].downcase,
      :email => user_email 
    }
    query[:credentials] = JSON.generate(query[:credentials])
    plaid_test_credentials query
    query
  end

  def plaid_test_credentials query
    if query[:username] = "plaid_test"
      query[:client_id] = "test_id"
      query[:secret] = "test_secret"
    end
    query
  end

  def type_if_sandbox! query, name
    # the api requires this in sandbox mode
    if query[:username] = "plaid_test"
      query[:type] = name
    end
    query
  end
end
